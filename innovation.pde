class innovation {
  List<Integer> history;
  int fromNode, toNode, id;
  
  innovation(List<Integer> history, int fromNode, int toNode, int id){
    this.history = new ArrayList<Integer>(history);
    this.fromNode = fromNode;
    this.toNode = toNode;
    this.id = id;
  }
  
  boolean sameInnovation(genome g, int fromNode, int toNode){
    if(history.equals(g.history) && this.fromNode == fromNode && this.toNode == toNode){
      return true;
    }
    return false;
  }
}
