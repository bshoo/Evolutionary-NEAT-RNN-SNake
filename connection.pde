class connection {
  int from, to, innoNo;
  float weight;
  boolean enable;
  
  connection(int from, int to, float weight, boolean enable, int innoNo){
    this.from = from;
    this.to = to;
    this.weight = weight;
    this.enable = enable;
    this.innoNo = innoNo;
  }
  
  connection(connection c){
    this(c.from, c.to, c.weight, c.enable, c.innoNo);
  }
  
  void disable(){
    enable = false;
  }
  
  void enable(){
    enable = true;
  }
}
