extends Node2D

var velas_restantes : int = 13
var turno_jogador : bool = true
var jogo_acabou : bool = false

@onready var container_velas = $VelasContainer
@onready var mensagem = $Mensagem
@onready var btn_1 = $BotoesContainer/Btn1
@onready var btn_2 = $BotoesContainer/Btn2
@onready var btn_3 = $BotoesContainer/Btn3
@onready var btn_reiniciar = $BotoesContainer/BtnReiniciar

func _ready():
	# Conecta os botões via código para você não precisar fazer isso no editor
	btn_1.pressed.connect(_on_apagar.bind(1))
	btn_2.pressed.connect(_on_apagar.bind(2))
	btn_3.pressed.connect(_on_apagar.bind(3))
	btn_reiniciar.pressed.connect(reiniciar_jogo)
	
	btn_reiniciar.hide()
	atualizar_interface()

func atualizar_interface():
	# Atualiza o texto superior
	if not jogo_acabou:
		if turno_jogador:
			mensagem.text = "Sua vez, viajante. " + str(velas_restantes) + " velas no altar."
		else:
			mensagem.text = "A assombração está decidindo... " + str(velas_restantes) + " velas no altar."
	
	# Limpa o container de velas
	for filho in container_velas.get_children():
		filho.queue_free()
		
	# Desenha visualmente a quantidade de velas restantes
	for i in range(velas_restantes):
		var vela = ColorRect.new()
		vela.custom_minimum_size = Vector2(30, 80)
		vela.color = Color(0.9, 0.4, 0.1) # Laranja fogo
		container_velas.add_child(vela)

func _on_apagar(quantidade: int):
	if jogo_acabou or not turno_jogador: return
	
	if quantidade > velas_restantes:
		quantidade = velas_restantes
		
	velas_restantes -= quantidade
	verificar_fim_de_jogo("Viajante")
	
	if not jogo_acabou:
		turno_jogador = false
		botoes_estado(false)
		atualizar_interface()
		turno_da_assombracao()

func turno_da_assombracao():
	# Suspense cabuloso de 1.5 segundos
	await get_tree().create_timer(1.5).timeout
	
	var quantidade_a_apagar = 1
	
	# 30% de chance de a assombração errar a jogada perfeita
	if randf() < 0.3:
		quantidade_a_apagar = randi_range(1, min(3, velas_restantes))
	else:
		var alvo_ideal = (velas_restantes - 1) % 4
		if alvo_ideal > 0 and alvo_ideal <= 3:
			quantidade_a_apagar = alvo_ideal
		else:
			quantidade_a_apagar = randi_range(1, min(3, velas_restantes))
		
	velas_restantes -= quantidade_a_apagar
	verificar_fim_de_jogo("Assombração")
	
	if not jogo_acabou:
		turno_jogador = true
		botoes_estado(true)
		atualizar_interface()

func verificar_fim_de_jogo(quem_jogou_por_ultimo: String):
	if velas_restantes <= 0:
		jogo_acabou = true
		botoes_estado(false)
		btn_reiniciar.show()
		
		if quem_jogou_por_ultimo == "Viajante":
			mensagem.text = "A última chama se apagou. A assombração levou sua alma..."
			mensagem.modulate = Color(1, 0, 0) # Fica vermelho
		else:
			mensagem.text = "A assombração apagou a última chama. Você sobreviveu à noite."
			mensagem.modulate = Color(0, 1, 0) # Fica verde
		
		# Limpa a última vela da tela
		for filho in container_velas.get_children():
			filho.queue_free()

func botoes_estado(estado: bool):
	# Habilita ou desabilita os botões dependendo de quem é a vez e quantas velas sobram
	btn_1.disabled = not estado or velas_restantes < 1
	btn_2.disabled = not estado or velas_restantes < 2
	btn_3.disabled = not estado or velas_restantes < 3

func reiniciar_jogo():
	velas_restantes = 13
	turno_jogador = true
	jogo_acabou = false
	mensagem.modulate = Color(1, 1, 1) # Volta pro branco
	botoes_estado(true)
	btn_reiniciar.hide()
	atualizar_interface()
