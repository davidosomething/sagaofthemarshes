DECLARE FUNCTION RandomDir% ()
DECLARE FUNCTION InvertDir% (whichDir%)
DECLARE FUNCTION FindPlayer% (whichChara%, whichTry%)
DECLARE SUB BattleChara (whichChara%)
DECLARE SUB EnemyAttack (whichChara%, whichDir%)
DECLARE SUB AnimateMove (whichChara%)
DECLARE SUB AttackChara (whichChara%)
DECLARE SUB BattleMenu (whichChara%)
DECLARE SUB CheckBattle ()
DECLARE FUNCTION CheckTile% (whichChara%, whichDir%)
DECLARE SUB CreateBox (boundX1%, boundY1%, boundX2%, boundY2%, border%, fill%)
DECLARE SUB CreateMenu (boundY%, boundX%, options%)
DECLARE SUB DisplayBMap (displayMode%)
DECLARE SUB DisplayChara (whichChara%)
DECLARE SUB DisplayCursor (highlight%)
DECLARE SUB DisplayDamage (amount%)
DECLARE SUB DisplayDebug (whichChara%)
DECLARE SUB DisplayStats (whichChara%)
DECLARE SUB EnemyLoop (whichChara%)
DECLARE SUB GameOver ()
DECLARE FUNCTION GetDirection% (move$)
DECLARE SUB LoadEnemies ()
DECLARE SUB LoadMap ()
DECLARE SUB MoveChara (whichChara%, whichDir%)
DECLARE SUB MoveCursor (whichDir%)
DECLARE SUB NewGame ()
DECLARE SUB Pause ()
DECLARE SUB PlayerAttack (whichChara%)
DECLARE SUB PlayerFace (whichChara%)
DECLARE SUB PlayerLoop (whichChara%)
DECLARE SUB PlayerMove (whichChara%)
DECLARE SUB SetChara (whichChara%)
DECLARE SUB StoreMove (whichChara%, whichDir%, startAP%)
DECLARE SUB WinBattle ()
DECLARE SUB EnemyMove (whichChara%, whichDir%, whichMode%)
DECLARE FUNCTION GetType% (getString$, whichChara%)
DECLARE FUNCTION EnemyAdjacent% (whichChara%)

'$DYNAMIC
DEFINT A-Z
COMMON SHARED players, enemies
COMMON SHARED cursorX, cursorY
COMMON SHARED endTurn, finished, selected
OPTION BASE 1
DIM SHARED battleMap(16, 12)
DIM SHARED moveX(9), moveY(9), moveZ(9)
DIM SHARED charaName$(6), charaType$(6)
DIM SHARED charaMHP(6), charaCHP(6)
DIM SHARED charaMAP(6), charaCAP(6)
DIM SHARED charaBX(6), charaBY(6), charaBZ(6)
DIM SHARED charaSPD(6), charaATK(6), charaDEF(6)

RANDOMIZE TIMER
SCREEN 13
VIEW (0, 0)-(319, 199)

LoadMap
DisplayBMap 0

NewGame
LoadEnemies

DO
FOR checkSPD = 999 TO 1 STEP -1
  FOR whichTurn = 1 TO 6
    IF charaSPD(whichTurn) = checkSPD AND charaCHP(whichTurn) THEN
      charaCAP(whichTurn) = charaMAP(whichTurn)
      SetChara whichTurn
      IF whichTurn < 4 THEN PlayerLoop whichTurn ELSE EnemyLoop whichTurn
    END IF
  NEXT whichTurn
NEXT checkSPD
LOOP

battleMap1:
DATA 00,00,00,00,10,10,00,00,00,00,00,00,10,10,00,00
DATA 00,00,00,00,10,10,10,00,00,00,00,00,00,00,10,00
DATA 00,00,00,00,00,10,00,00,00,00,00,00,00,10,00,00
DATA 00,00,00,10,10,00,00,00,00,00,00,00,00,00,00,00
DATA 00,00,00,00,00,10,00,00,00,00,00,00,00,10,00,00
DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,10,00,00
DATA 00,00,00,00,10,10,00,00,00,00,00,00,10,10,00,00
DATA 00,00,00,00,10,10,10,00,00,00,00,00,00,00,00,00
DATA 00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00
DATA 00,00,00,10,10,00,00,00,00,00,00,00,00,00,00,00
DATA 00,00,00,00,00,10,00,00,00,00,00,00,00,10,00,00
DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

REM $STATIC
SUB AnimateMove (whichChara)
FOR checkStep = charaMAP(whichChara) TO charaCAP(whichChara) + 1 STEP -1
  MoveChara whichChara, moveZ(checkStep)
NEXT checkStep
END SUB

SUB AttackChara (whichChara)
target = CheckTile(0, 0)
damage = INT(RND * charaATK(whichChara)) + (charaDEF(target) \ 2)
charaCHP(target) = charaCHP(target) - damage
IF charaCHP(target) < 0 THEN charaCHP(target) = 0

DisplayDamage damage
DisplayStats target
Pause

charaCAP(whichChara) = charaCAP(whichChara) - 2
CheckBattle
END SUB

SUB BattleChara (whichChara)
  SetChara whichChara
  DisplayChara whichChara
  DisplayStats whichChara
  DisplayCursor 55
END SUB

SUB BattleMenu (whichChara)

  LOCATE 6, 21: PRINT "Move"
  LOCATE 7, 21: PRINT "Attack"
  LOCATE 8, 21: PRINT "Skill"
  LOCATE 9, 21: PRINT "Item"
  LOCATE 10, 21: PRINT "Status"
  LOCATE 11, 21: PRINT "Finished"

DO
  BattleChara whichChara
  CreateMenu 5, 19, 6
  IF finished = 1 THEN
    IF selected = 1 AND charaCAP(whichChara) > 0 THEN PlayerMove whichChara
    IF selected = 2 AND charaCAP(whichChara) > 1 THEN PlayerAttack whichChara
    IF selected = 6 THEN endTurn = 1
  END IF
  IF finished = -1 THEN endTurn = -1
LOOP UNTIL endTurn

COLOR 0

  LOCATE 6, 21: PRINT "Move"
  LOCATE 7, 21: PRINT "Attack"
  LOCATE 8, 21: PRINT "Skill"
  LOCATE 9, 21: PRINT "Item"
  LOCATE 10, 21: PRINT "Status"
  LOCATE 11, 21: PRINT "Finished"

COLOR 15
END SUB

SUB CheckBattle
deadPlayers = 0
deadEnemies = 0

FOR whichChara = 1 TO players
  IF charaCHP(whichChara) = 0 THEN deadPlayers = deadPlayers + 1
NEXT whichChara

FOR whichChara = 4 TO 3 + enemies
  IF charaCHP(whichChara) = 0 THEN deadEnemies = deadEnemies + 1
NEXT whichChara

LOCATE 17, 20: PRINT "dP: "; deadPlayers
LOCATE 18, 20: PRINT "dE: "; deadEnemies

IF deadPlayers = players THEN GameOver
IF deadEnemies = enemies THEN WinBattle
END SUB

FUNCTION CheckTile (whichChara, whichDir)
' -2 = terrain obstacle
' -1 = walkable tile
'  0 = out of bounds
' >0 = character

IF whichChara THEN
  checkX = charaBX(whichChara)
  checkY = charaBY(whichChara)
ELSE
  checkX = cursorX
  checkY = cursorY
END IF

  SELECT CASE whichDir
    CASE 1: checkY = checkY - 1
    CASE 2: checkY = checkY + 1
    CASE 3: checkX = checkX - 1
    CASE 4: checkX = checkX + 1
  END SELECT

  FOR checkChara = 1 TO 6
    IF checkChara <> whichChara THEN
      IF checkX = charaBX(checkChara) AND checkY = charaBY(checkChara) THEN
        CheckTile = checkChara
        EXIT FUNCTION
      END IF
    END IF
  NEXT checkChara

  IF checkX > 0 AND checkX < 17 AND checkY > 0 AND checkY < 13 THEN
    IF battleMap(checkX, checkY) < 10 THEN
      CheckTile = -1
      ELSE CheckTile = -2
    END IF
  END IF
END FUNCTION

SUB CreateBox (boundX1, boundY1, boundX2, boundY2, border, fill)
  IF border > 0 THEN
    LINE (boundX1, boundY1)-(boundX2, boundY2), border, B
    IF fill THEN PAINT (boundX1 + 8, boundY1 + 8), fill, border
  ELSEIF border < 0 THEN
    LINE (boundX1, boundY1)-(boundX2, boundY2), 0, BF
  END IF
END SUB

SUB CreateMenu (boundY, boundX, options)
finished = 0
selected = 1

DO
  LOCATE selected + boundY, boundX: PRINT "ø"
  DO: move$ = INKEY$: LOOP UNTIL move$ <> ""
  LOCATE selected + boundY, boundX: PRINT " "

  IF move$ = CHR$(0) + "H" THEN
    IF selected > 1 THEN
      selected = selected - 1
    ELSE selected = options
    END IF
  END IF

  IF move$ = CHR$(0) + "P" THEN
    IF selected < options THEN
      selected = selected + 1
    ELSE selected = 1
    END IF
  END IF

  IF move$ = " " THEN finished = 1
  IF move$ = CHR$(27) THEN finished = -1
LOOP UNTIL finished
END SUB

SUB DisplayBGrid (displayMode)
IF gridMode > 0 THEN
  boundX1 = charaBX(displayMode) - 1
  boundY1 = charaBY(displayMode) - 1
  boundX2 = charaBX(displayMode) - 1
  boundY2 = charaBY(displayMode) - 1
ELSEIF gridMode = 0 THEN
  boundX1 = 0
  boundY1 = 0
  boundX2 = 15
  boundY2 = 11
END IF

FOR gridY = boundY1 TO boundY2
  FOR gridX = boundX1 TO boundX2
    LINE (gridX * 8, gridY * 8)-(gridX * 8 + 8, gridY * 8 + 8), 2, B
  NEXT gridX
NEXT gridY
END SUB

SUB DisplayBMap (displayMode)
IF displayMode > 0 THEN
  boundX1 = charaBX(displayMode)
  boundY1 = charaBY(displayMode)
  boundX2 = charaBX(displayMode)
  boundY2 = charaBY(displayMode)
ELSEIF displayMode = 0 THEN
  boundX1 = 1
  boundY1 = 1
  boundX2 = 16
  boundY2 = 12
END IF

FOR displayY = boundY1 TO boundY2
  FOR displayX = boundX1 TO boundX2
    LOCATE displayY, displayX
    IF battleMap(displayX, displayY) = 0 THEN COLOR 6: PRINT "."
    IF battleMap(displayX, displayY) = 10 THEN COLOR 2: PRINT "!"
  NEXT displayX
NEXT displayY
END SUB

SUB DisplayChara (whichChara)
  LOCATE charaBY(whichChara), charaBX(whichChara)

  IF charaCHP(whichChara) > 0 THEN
    COLOR whichChara * 2 + 20
  ELSE COLOR 12
  END IF

  SELECT CASE charaBZ(whichChara)
    CASE 1: PRINT "Á"
    CASE 2: PRINT "Â"
    CASE 3: PRINT "´"
    CASE 4: PRINT "Ã"
  END SELECT
  COLOR 15
END SUB

SUB DisplayCursor (highlight)
  LINE ((cursorX - 1) * 8 - 1, (cursorY - 1) * 8 - 1)-((cursorX - 1) * 8 + 8, (cursorY - 1) * 8 + 7), highlight, B
END SUB

SUB DisplayDamage (amount)
LOCATE 18, 4: PRINT "Hit for "; amount; "HP!"
END SUB

SUB DisplayDebug (whichChara)
  LOCATE 22, 19
  PRINT "CX: "; cursorX; " CY: "; cursorY

  LOCATE 23, 20
  PRINT "X: "; charaBX(whichChara); "  Y: "; charaBY(whichChara)
END SUB

SUB DisplayError (message$)
 COLOR 12: LOCATE 21, 10: PRINT message$
 Pause
 COLOR 0: LOCATE 21, 10: PRINT message$
END SUB

SUB DisplayStats (whichChara)
  LOCATE 1, 20
  PRINT "Name: "; charaName$(whichChara)

  LOCATE 3, 20
  PRINT "HP: "; charaCHP(whichChara); "/"; charaMHP(whichChara)

  LOCATE 4, 20
  PRINT "AP: "; charaCAP(whichChara); "/"; charaMAP(whichChara)
END SUB

FUNCTION EnemyAdjacent (whichChara)
  FOR checkDirection = 1 TO 4
    IF CheckTile(whichChara, checkDirection) > 0 AND CheckTile(whichChara, checkDirection) < 4 THEN
      IF adjacent THEN
        IF (RND * 2 + 1) > 3 THEN adjacent = checkDirection
      ELSE adjacent = checkDirection
      END IF
    END IF
  NEXT checkDirection
  EnemyAdjacent = adjacent
END FUNCTION

SUB EnemyAttack (whichChara, whichDir)
IF whichDir < 10 THEN
  SetChara whichChara
  MoveCursor whichDir
  AttackChara whichChara
END IF
END SUB

SUB EnemyLoop (whichChara)
DO
  BattleChara whichChara

  adjacent = EnemyAdjacent(whichChara)
  IF adjacent THEN
    IF GetType("Melee", whichChara) THEN
      WHILE charaCAP(whichChara) > 1: EnemyAttack whichChara, adjacent: WEND
      IF charaCAP(whichChara) THEN
        IF GetType("Towards", whichChara) OR GetType("Away", whichChara) THEN EnemyMove whichChara, adjacent, -1
        endTurn = 1
      END IF
    END IF
  ELSEIF GetType("Towards", whichChara) THEN EnemyMove whichChara, 0, 1
  ELSEIF GetType("Random", whichChara) THEN EnemyMove whichChara, 0, 0
  ELSEIF GetType("Away", whichChara) THEN EnemyMove whichChara, 0, -1
  ELSEIF GetType("Idle", whichChara) THEN endTurn = 1
  END IF
LOOP UNTIL endTurn OR charaCAP(whichChara) = 0
endTurn = 0
DisplayStats whichChara
END SUB

SUB EnemyMove (whichChara, whichDir, whichMode)
IF whichMode = 0 THEN whichDir = RandomDir
IF whichDir = 0 THEN whichDir = FindPlayer(whichChara, 0)
IF whichMode = -1 THEN whichDir = InvertDir(whichDir)

'------------------------------------------------ move enemy in direction --
DO
target = CheckTile(0, whichDir)            '-- make sure tile is walkable --
IF target <> -1 THEN                       '-- otherwise change direction --
  IF whichTry < 2 AND whichMode THEN whichDir = FindPlayer(whichChara, whichTry) ELSE whichDir = RandomDir
  IF whichMode = -1 THEN whichDir = InvertDir(whichDir)
  IF whichTry < 3 THEN whichTry = whichTry + 1
END IF
LOOP UNTIL target = -1
MoveChara whichChara, whichDir             '-- actual movement
charaCAP(whichChara) = charaCAP(whichChara) - 1

END SUB

FUNCTION FindPlayer (whichChara, whichTry)
REDIM playerX(3), playerY(3), playerDist(3)
closeY = 99: closeX = 99
FOR cP = 1 TO players
  playerX(cP) = charaBX(whichChara) - charaBX(cP)       ' enemy's - player's
  playerY(cP) = charaBY(whichChara) - charaBY(cP)
  playerDist(cP) = ABS(playerX(cP)) + ABS(playerY(cP))
NEXT cP
FOR check = 1 TO 3
FOR nearest = 1 TO players - 1
  IF playerDist(nearest) > playerDist(nearest + 1) THEN 'if the first stored
    SWAP playerX(nearest), playerX(nearest + 1)         'is further than the
    SWAP playerY(nearest), playerY(nearest + 1)         'next, swap them
    SWAP playerDist(nearest), playerDist(nearest + 1)
  END IF
NEXT nearest                                            'by the end, it sorts
NEXT check                                              'closest to furthest

'find if it has to move hori or vert by comparing closest's X and Y
IF ABS(playerX(1)) > ABS(playerY(1)) THEN
  IF whichTry = 0 THEN
    IF playerX(1) > 0 THEN FindPlayer = 3 ELSE FindPlayer = 4
  ELSE
    IF playerY(1) > 0 THEN FindPlayer = 1 ELSE FindPlayer = 2
  END IF
ELSE
  IF whichTry = 0 THEN
    IF playerY(1) > 0 THEN FindPlayer = 1 ELSE FindPlayer = 2
  ELSE
    IF playerX(1) > 0 THEN FindPlayer = 3 ELSE FindPlayer = 4
  END IF
END IF

END FUNCTION

SUB GameOver
SYSTEM
END SUB

FUNCTION GetDirection (move$)
  IF move$ = CHR$(0) + "H" THEN GetDirection = 1
  IF move$ = CHR$(0) + "P" THEN GetDirection = 2
  IF move$ = CHR$(0) + "K" THEN GetDirection = 3
  IF move$ = CHR$(0) + "M" THEN GetDirection = 4
END FUNCTION

FUNCTION GetType (getString$, whichChara)
  GetType = INSTR(charaType$(whichChara), getString$)
END FUNCTION

FUNCTION InvertDir (whichDir)
  IF (whichDir MOD 2) = 1 THEN InvertDir = whichDir + 1 ELSE InvertDir = whichDir - 1
END FUNCTION

SUB LoadEnemies
charaBX(4) = 1
charaBY(4) = 5
charaBZ(4) = 2
charaType$(4) = "Melee.Towards"

charaBX(5) = 8
charaBY(5) = 2
charaBZ(5) = 2
charaType$(5) = "Melee.Idle"


FOR whichChara = 4 TO 3 + enemies
  charaName$(whichChara) = "Enemy #" + STR$(whichChara - 3)
  charaMHP(whichChara) = 50
  charaCHP(whichChara) = 12
  charaMAP(whichChara) = 3
  charaCAP(whichChara) = charaMAP(whichChara)
  charaSPD(whichChara) = 7 - whichChara
  charaATK(whichChara) = 8
  charaDEF(whichChara) = 6
  DisplayChara whichChara
NEXT whichChara

END SUB

SUB LoadMap
RESTORE battleMap1
FOR loadY = 1 TO 12
  FOR loadX = 1 TO 16
    READ battleMap(loadX, loadY)
  NEXT loadX
NEXT loadY

enemies = 2
END SUB

SUB MoveChara (whichChara, whichDir)
  charaBZ(whichChara) = whichDir
  DisplayBMap whichChara
  SELECT CASE whichDir
    CASE 1: charaBY(whichChara) = charaBY(whichChara) - 1
    CASE 2: charaBY(whichChara) = charaBY(whichChara) + 1
    CASE 3: charaBX(whichChara) = charaBX(whichChara) - 1
    CASE 4: charaBX(whichChara) = charaBX(whichChara) + 1
  END SELECT
  DisplayChara whichChara
END SUB

SUB MoveCursor (whichDir)
IF CheckTile(0, whichDir) THEN
  SELECT CASE whichDir
    CASE 1: cursorY = cursorY - 1
    CASE 2: cursorY = cursorY + 1
    CASE 3: cursorX = cursorX - 1
    CASE 4: cursorX = cursorX + 1
  END SELECT
END IF
END SUB

SUB NewGame
charaBX(1) = 1
charaBY(1) = 12
charaBZ(1) = 1

players = 1

FOR whichChara = 1 TO players
  charaName$(whichChara) = "Player # " + STR$(whichChara)
  charaMHP(whichChara) = 60
  charaCHP(whichChara) = 50
  charaMAP(whichChara) = 6
  charaSPD(whichChara) = 7 - whichChara
  charaATK(whichChara) = 8
  charaDEF(whichChara) = 6
  DisplayChara whichChara
NEXT whichChara
END SUB

SUB Pause
DO: LOOP UNTIL INKEY$ <> ""
END SUB

SUB PlayerAttack (whichChara)
DO
  target = CheckTile(0, 0)
  DisplayCursor 40
  IF target > 0 THEN DisplayStats CheckTile(0, 0)
  DO: move$ = INKEY$: LOOP UNTIL move$ <> ""
  IF LEN(move$) = 2 THEN
    whichDir = GetDirection(move$)
    IF whichDir THEN
      SetChara whichChara
      MoveCursor whichDir
    END IF
  END IF
  IF move$ = " " AND target > 0 AND target <> whichChara THEN
    IF charaCHP(target) > 0 THEN doneAttacking = 1
  END IF
  IF move$ = CHR$(27) THEN doneAttacking = -1
LOOP UNTIL doneAttacking
IF doneAttacking = 1 THEN
  charaBZ(whichChara) = whichDir
  AttackChara whichChara
END IF
END SUB

SUB PlayerFace (whichChara)
CreateBox 40, 120, 200, 160, 1, 8
LOCATE 17, 8: PRINT "Choose direction"
LOCATE 18, 8: PRINT "to face."

DO
  DisplayChara whichChara
  DO: move$ = INKEY$: LOOP UNTIL move$ <> ""
  IF LEN(move$) = 2 THEN charaBZ(whichChara) = GetDirection(move$)
  IF move$ = " " THEN doneFacing = 1
LOOP UNTIL doneFacing
CreateBox 40, 120, 200, 160, -1, 0
END SUB

SUB PlayerLoop (whichChara)
DO
  DisplayDebug whichChara
  'DisplayBGrid whichChara
  DisplayCursor 55
  DO: move$ = INKEY$: LOOP UNTIL move$ <> ""
  DisplayCursor 0
  IF move$ = CHR$(27) THEN SetChara whichChara
  IF move$ = CHR$(0) + "H" THEN MoveCursor 1
  IF move$ = CHR$(0) + "P" THEN MoveCursor 2
  IF move$ = CHR$(0) + "K" THEN MoveCursor 3
  IF move$ = CHR$(0) + "M" THEN MoveCursor 4
  
  IF move$ = " " THEN
    IF CheckTile(0, 0) = whichChara THEN
      BattleMenu whichChara
    ELSEIF CheckTile(0, 0) > 0 THEN
      DisplayStats CheckTile(0, 0)
      Pause
    END IF
  END IF

  IF UCASE$(move$) = "Q" THEN SYSTEM
LOOP UNTIL endTurn = 1
endTurn = 0
charaCAP(whichChara) = 0
PlayerFace whichChara
END SUB

SUB PlayerMove (whichChara)
REDIM moveX(9), moveY(9), moveZ(9)
startAP = charaCAP(whichChara)
DO
  DisplayStats whichChara
  DisplayCursor 44
  DO: move$ = INKEY$: LOOP UNTIL move$ <> ""
  IF LEN(move$) = 2 THEN
    whichDir = GetDirection(move$)
    IF whichDir THEN StoreMove whichChara, whichDir, startAP
  END IF
  IF move$ = " " THEN doneMoving = 1
  IF move$ = CHR$(27) THEN doneMoving = -1
LOOP UNTIL doneMoving
IF doneMoving = 1 THEN
  AnimateMove whichChara
ELSEIF doneMoving = -1 THEN charaCAP(whichChara) = startAP
END IF
END SUB

FUNCTION RandomDir
  RandomDir = INT(RND * 4) + 1
END FUNCTION

SUB SetChara (whichChara)
  DisplayCursor 0
  cursorX = charaBX(whichChara)
  cursorY = charaBY(whichChara)
END SUB

SUB StoreMove (whichChara, whichDir, startAP)
target = CheckTile(0, whichDir)

IF target = -1 THEN
  DisplayCursor 0
  MoveCursor whichDir

  FOR checkStep = charaCAP(whichChara) + 1 TO charaMAP(whichChara)
    IF moveY(checkStep) = cursorY AND moveX(checkStep) = cursorX THEN
      charaCAP(whichChara) = checkStep - 1
      EXIT SUB
    END IF
  NEXT checkStep

  IF charaCAP(whichChara) > 0 THEN
    moveX(charaCAP(whichChara)) = cursorX
    moveY(charaCAP(whichChara)) = cursorY
    moveZ(charaCAP(whichChara)) = whichDir
    charaCAP(whichChara) = charaCAP(whichChara) - 1
  ELSEIF whichDir = 1 OR whichDir = 3 THEN MoveCursor whichDir + 1
  ELSEIF whichDir = 2 OR whichDir = 4 THEN MoveCursor whichDir - 1
  END IF

ELSEIF target = whichChara THEN
  SetChara whichChara
  charaCAP(whichChara) = startAP
END IF
END SUB

SUB WinBattle
SYSTEM
END SUB

