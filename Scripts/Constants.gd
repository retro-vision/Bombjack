extends Area2D

const BOMB_IDLE_POINTS	 = 100
const BOMB_ACTIVE_POINTS = 200
const BONUS_JUMP = 10
const MAX_BOT = 4
const BOT_TIMER = 3

const SPEED_BIRD 	= Vector2(0.6,0.6)
const SPEED_ENEMY = Vector2(40,40)

# Joue tous les sons et musiques du jeu
var PLAY_SOUND
# Varibles initialisées dans Menu.gd
var level	= 1 # Niveau courant
var current_level = 1 # Niveau à afficher dans le panneau
var score	= 0 # Score courant
var lives	= 3 # Total des vies
var NbBombs	= 0 # Nombres de bombes gobées
var nbRobot	= 1 # Compteur d'apparition des robots
var firstBot = false
var botInitPos = Vector2(0,0) # Pos du 1er niveau
var deadOrWinerBJ = false
var cheat = false

var bonusFactor 	 	= 0 # Facteur multiplicateur de points
var bonusFireBombs 	= 0 # Bonus des bombes allumées en fin de niveau
#var fireBombs 		 	= 0 # Nombre de firebombs
var nbFireBombs		= 0 # Compteur de bombes allumées gobées pour bonus de fin de niveau
var powerballPoint 	= 0.0 # Compteur pour faire apparaitre la powerball
var powerballActive	= false # Semaphore pour n'avoir toujours qu'une powerball active
var deadBird = false

var PBColors = ['Blue', 'Red', 'Purple', 'Green', 'Cyan', 'Yellow', 'Grey']
var PBPoints = [100, 200, 300, 500, 800, 1200, 2000]

var dontMoveEnemy = false # Fige les ennemies pendant la powerball
var reTimer	= false # Timer pour la réapparition des robots

var fullscreen = false

var hiScores = Dictionary()
var putScore = false
const FILE_NAME_SCORES = 'res://HiScores.dat'
