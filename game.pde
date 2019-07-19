class game {
  boolean[][] board;
  List<int[]> tail;
  int[] head;
  int[] food;
  int[] ULC; //Upper-Left corner coordinates
  int length; //Does not include head
  int baseLength;
  int hunger;
  int lifetime;
  PVector direction;
  boolean dead;
  
  float[] prevOutput;

  //----Constructors----

  game(int x1, int y1, int x2, int y2, int foodx, int foody, int baseLength) {
    int[] ULC = {x1, y1};
    this.ULC = ULC;
    board = new boolean[(x2-x1)/20][(y2-y1)/20];
    int[] head = {board.length/2, board[0].length/2};
    this.head = head;
    int[] food = {foodx, foody};
    this.food = food;
    length = baseLength;
    this.baseLength = baseLength;
    hunger = 100;
    direction = new PVector(0, 1); //Down
    tail = new ArrayList<int[]>();
    for (int i = 0; i < baseLength; i++) {
      tail.add(head);
    }
    lifetime = 0;
    dead = false;
    prevOutput = new float[numOutputs];
    for(int i = 0; i < prevOutput.length; i++){
      prevOutput[i] = 0;
    }
  }

  game(game g, int foodx, int foody) {
    this(g.ULC[0], g.ULC[1], g.ULC[0] + g.board.length * 20, g.ULC[1] + g.board[0].length * 20, foodx, foody, g.baseLength);
  }

  game(int x1, int y1, int x2, int y2, int foodx, int foody) {
    this(x1, y1, x2, y2, foodx, foody, 0);
  }
  
  //----NN Interface----
  
  void update(float[] outputs){
    float[] turnOutputs = Arrays.copyOf(outputs, 4);
    int turn = 0;
    for(int i = 0; i < turnOutputs.length; i++){
      if(turnOutputs[i] > turnOutputs[turn]){
        turn = i;
      }
    }
    direction.set(0,-1);
    direction.rotate(HALF_PI * turn);
    direction.x = round(direction.x); //Sometimes rotating isn't exact, so we round to compensate
    direction.y = round(direction.y);
    for(int i = 0; i < outputs.length; i++){
      prevOutput[i] = outputs[i];
    }
    nextStep();
  }
  
  float[] getData(){
    float[] data = new float[numOutputs + 49 + 4]; //Previous outputs + 7x7 square centered around the head + 2 food position + 2 head position
    int currentIndex = 0;
    for(int i = 0; i < numOutputs; i++, currentIndex++){
      data[currentIndex] = prevOutput[i];
    }
    for(int i = -3; i <= 3; i++){
      for(int j = -3; j <= 3; j++){
        if(head[0] + i < 0 || head[0] + i >= board.length || head[1] + j < 0 || head[1] + j >= board[0].length){
          data[currentIndex] = 1;
          currentIndex++;
          continue;
        }
        if(board[head[0] + i][head[1] + j]){
          data[currentIndex] = 1;
          currentIndex++;
          continue;
        } else {
          data[currentIndex] = 0;
          currentIndex++;
        }
      }
    }
    data[currentIndex++] = (float)food[0]/board.length;
    data[currentIndex++] = (float)food[1]/board[0].length;
    data[currentIndex++] = (float)head[0]/board.length;
    data[currentIndex++] = (float)head[1]/board[0].length;
    return data;
  }
  
  float fitness(){
    return pow(length-baseLength,4);
  }

  //----Game----

  void nextStep() {
    if (!dead && !(direction.x == 0 && direction.y == 0)) {
      lifetime++;
      hunger--;
      tail();
      head[0] += direction.x;
      head[1] += direction.y;
      if (head[0] == food[0] && head[1] == food[1]) {
        addTail();
        randomizeFood();
        hunger += 100 * max(1, (length-baseLength)/20);
      }
      dead = checkDead();
    }
  }

  void tail() { //Handles tail
    if (length > 0) {
      board[tail.get(tail.size() - 1)[0]][tail.get(tail.size() - 1)[1]] = false;
      board[head[0]][head[1]] = true;
      for (int i = tail.size() - 1; i > 0; i--) {
        tail.set(i, Arrays.copyOf(tail.get(i-1), tail.get(i-1).length));
      }
      tail.set(0, Arrays.copyOf(head, head.length));
    }
  }

  void addTail() {
    tail.add(tail.get(tail.size() - 1));
  }

  void randomizeFood() {
    while (board[food[0]][food[1]] == true || (food[0] == head[0] && food[1] == head[1])) {
      food[0] = (int)random(board.length);
      food[1] = (int)random(board[0].length);
    }
  }

  boolean checkDead() {
    if (dead || hunger == 0) { //Starved
      return true;
    }
    if (head[0] < 0 || head[1] < 0 || head[0] >= board.length || head[1] >= board[0].length) { //Out of bounds
      return true;
    }
    if (board[head[0]][head[1]]) { //Self collision
      return true;
    }
    return false;
  }

  void show() {
    if (dead == false) {
      fill(255);
      noStroke();
      for (int[] segment : tail) {
        rect(ULC[0] + 20 * segment[0] + 1, ULC[1] + 20 * segment[1] + 1, 18, 18, 4);
      }
      fill(200);
      rect(ULC[0] + 20 * head[0] + 1, ULC[1] + 20 * head[1] + 1, 18, 18, 4);
      fill(#f56342);
      rect(ULC[0] + 20 * food[0] + 1, ULC[1] + 20 * food[1] + 1, 18, 18, 4);
      String hunger = "Food Left: " + this.hunger;
      String length = "Points Gotten: " + (this.length - this.baseLength);
      fill(255);
      text(hunger, ULC[0] + 10, ULC[1] + 20);
      text(length, ULC[0] + 10, ULC[1] + 40);
    }
  }
}
