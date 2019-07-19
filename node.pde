class node {
  List<Integer> relevantConnections;
  boolean isInput;
  boolean isOutput;
  int layer;
  
  node(boolean isInput, boolean isOutput){
    relevantConnections = new ArrayList<Integer>();
    this.isInput = isInput;
    this.isOutput = isOutput;
    layer = 0;
  }
  
  node(node n){
    relevantConnections = new ArrayList<Integer>(n.relevantConnections);
    isInput = n.isInput;
    isOutput = n.isOutput;
    layer = n.layer;
  }
}
