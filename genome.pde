class genome { //<>//
  List<node> nodes;
  List<connection> connections;
  List<Integer> history;
  List<Float> nodeOutputs;
  int layers;
  game g;
  int id;

  genome(int inputs, int outputs, int id) {
    nodes = new ArrayList<node>();
    connections = new ArrayList<connection>();
    history = new ArrayList<Integer>();
    for (int i = 0; i < inputs; i++) {
      nodes.add(new node(true, false));
    }
    for (int i = 0; i < outputs; i++) {
      nodes.add(new node(false, true));
      nodes.get(nodes.size() - 1).layer = 1;
      for (int j = inputs - 4; j < inputs; j++) {
        addConnection(j, nodes.size() - 1);
      }
    }
    layers = 2;
    nodeOutputs = new ArrayList<Float>();
    g = new game(0, 0, height, height, (int)random(height/20), (int)random(height/20), startingLength);
    this.id = id;
  }

  genome(genome g) { //Clones genome g
    nodes = new ArrayList<node>();
    for (node n : g.nodes) {
      nodes.add(new node(n));
    }
    connections = new ArrayList<connection>();
    for (connection c : g.connections) {
      connections.add(new connection(c));
    }
    history = new ArrayList<Integer>(g.history);
    layers = g.layers;
    nodeOutputs = new ArrayList<Float>();
    this.g = new game(0, 0, height, height, (int)random(height/20), (int)random(height/20), startingLength);
    id = g.id;
  }

  float activation(float in) { //Change this to tanh if randomGaussian is changed to random(1)
    return (float)Math.tanh(in);
  }

  void update() {
    g.update(output(g.getData()));
  }

  void show() {
    g.show();
  }

  float[] output(float[] inputs) {
    nodeOutputs.clear();
    for (int i = 0; i < inputs.length; i++) {
      nodeOutputs.add(inputs[i]);
    }
    for (int i = inputs.length; i < nodes.size(); i++) {
      nodeOutputs.add(null);
    }
    int[] outputNodeIDs = getNodesLayer(layers - 1);
    float[] outputs = new float[outputNodeIDs.length];
    for (int i = 0; i < outputs.length; i++) {
      outputs[i] = nodeOutput(outputNodeIDs[i]);
    }
    return outputs;
  }

  float nodeOutput(int node) {
    if (nodeOutputs.get(node) != null) {
      return nodeOutputs.get(node);
    }
    float sum = 0;
    for (int i = 0; i < nodes.get(node).relevantConnections.size(); i++) {
      if (connections.get(nodes.get(node).relevantConnections.get(i)).enable) {
        sum += nodeOutput(connections.get(nodes.get(node).relevantConnections.get(i)).from) * connections.get(nodes.get(node).relevantConnections.get(i)).weight;
      }
    }
    nodeOutputs.set(node, activation(sum));
    return nodeOutput(node);
  }

  int[] getNodesLayer(int l) {
    List<Integer> NinL = new ArrayList<Integer>();
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).layer == l) {
        NinL.add(i);
      }
    }
    int[] out = new int[NinL.size()];
    for (int i = 0; i < NinL.size(); i++) {
      out[i] = NinL.get(i);
    }
    return out;
  }

  void addConnection(boolean checkForFull) {
    if (checkForFull) {
      if (fullyConnected()) {
        return;
      }
    }
    int[] newConnection = pickNewConnection();
    addConnection(newConnection[0], newConnection[1]);
  }

  void addConnection(int FN, int TN) {
    nodes.get(TN).relevantConnections.add(connections.size());
    connections.add(new connection(FN, TN, randomGaussian(), true, checkInnovation(FN, TN)));
    history.add(connections.get(connections.size() - 1).innoNo);
  }

  void addConnection(int FN, int TN, float weight) {
    nodes.get(TN).relevantConnections.add(connections.size());
    connections.add(new connection(FN, TN, weight, true, checkInnovation(FN, TN)));
    history.add(connections.get(connections.size() - 1).innoNo);
  }

  int[] pickNewConnection() {
    int[] newCon = new int[2]; //FN, TN
    newCon[1] = floor(random(nodes.size()));
    int[] possible = openConnections(newCon[1]);
    while (possible.length == 0) {
      newCon[1] = floor(random(nodes.size()));
      possible = openConnections(newCon[1]);
    }
    newCon[0] = possible[floor(random(possible.length))];    
    return newCon;
  }

  int[] openConnections(int TN) { //Find from-nodes that this to-node can connect to
    List<Integer> OC = new ArrayList<Integer>();
    for (int i = 0; i < nodes.size(); i++) {
      if (!nodes.get(i).isOutput && i != TN && nodes.get(i).layer < nodes.get(TN).layer && !connectionExists(i, TN)) {
        OC.add(i);
      }
    }
    int[] out = new int[OC.size()];
    for (int i = 0; i < OC.size(); i++) {
      out[i] = OC.get(i);
    }
    return out;
  }

  boolean fullyConnected() {
    int maxConnections = 0;
    int[] layerStructure = new int[layers];
    for (node n : nodes) {
      try {
        layerStructure[n.layer]++;
      } 
      catch (Exception NullPointerException) {
        println("error in fullyConnected()"); //<>//
      }
    }
    for (int i = layers - 1; i > 0; i--) {
      int nodesInFront = 0;
      for (int j = 0; j < i; j++) {
        nodesInFront += layerStructure[j];
      }
      maxConnections += nodesInFront * layerStructure[i];
    }
    return maxConnections == connections.size();
  }

  boolean connectionExists(int FN, int TN) {
    for (int i : nodes.get(TN).relevantConnections) {
      if (connections.get(i).from == FN) {
        return true;
      }
    }
    return false;
  }

  void addNode() {
    int connection = (int)random(connections.size());
    while (connections.get(connection).enable == false) {
      connection = (int)random(connections.size());
    }
    addNode(connections.get(connection));
  }

  void addNode(connection c) {
    c.disable();
    nodes.add(new node(false, false));
    nodes.get(nodes.size() - 1).layer = nodes.get(c.from).layer + 1;
    if (nodes.get(nodes.size() - 1).layer == nodes.get(c.to).layer) { //Move any nodes of the same layer or higher layers to their layer + 1 --> basically create a new layer and push the other ones to higher layers
      for (int i = 0; i < nodes.size() - 1; i++) { //Don't include the new node
        if (nodes.get(i).layer >= nodes.get(nodes.size() - 1).layer) {
          nodes.get(i).layer++;
        }
      }
      layers++; //Output node layer
    }
    addConnection(c.from, nodes.size() - 1, 1);
    addConnection(nodes.size() - 1, c.to, c.weight);
  }

  void mutateRandomWeights(int num) {
    for (int i = 0; i < num; i++) {
      int connection = (int)random(connections.size());
      if (random(1) < 0.25) {
        mutateWeight(connections.get(connection), 1);
      } else {
        mutateWeight(connections.get(connection), 0);
      }
    }
  }

  void mutateWeight(connection c, int bigOrSmall) {
    if (bigOrSmall == 0) { //Small
      c.weight += randomGaussian()/50;
    } else {
      c.weight = randomGaussian();
    }
  }

  float compatibilityDistance(genome g) {
    float cd = 0;
    int ed = 0; //Excess + Disjoint genes
    float awd = 0; //Average Weight Difference
    int sameGenes = 0;
    for (int i = 0; i < max(g.history.get(g.history.size() - 1), history.get(history.size() - 1)); i++) {
      if ((g.history.contains(i) && !history.contains(i)) || (!g.history.contains(i) && history.contains(i))) {
        ed++;
      } else if (g.history.contains(i) && history.contains(i)) {
        awd += abs(connections.get(history.indexOf(i)).weight - g.connections.get(g.history.indexOf(i)).weight);
        sameGenes++;
      }
    }
    awd /= (float)sameGenes;
    cd = (float)ed/(float)max(min(g.connections.size(), connections.size())-(numInputs * numOutputs), 1) + awd/3.0;
    return cd;
  }

  int checkInnovation(int FN, int TN) {
    for (innovation i : GIL) {
      if (i.sameInnovation(this, FN, TN)) {
        return i.id;
      }
    }
    GIL.add(new innovation(history, FN, TN, GIL.size()));
    return GIL.size() - 1;
  }

  float fitness() {
    return g.fitness();
  }

  void crossover(genome g) {
    for (Integer i : history) {
      int gInnoIndex = g.findIndexOfConnection(i);
      if (gInnoIndex == -1) {
        continue;
      }
      int innoIndex = findIndexOfConnection(i);
      connections.get(innoIndex).weight += g.connections.get(gInnoIndex).weight;
      connections.get(innoIndex).weight /= 2;
      connections.get(innoIndex).enable();
      if (!g.connections.get(gInnoIndex).enable || !connections.get(innoIndex).enable) {
        if (random(1) <= 0.5) {
          connections.get(innoIndex).disable();
        }
      }
    }
    int newNodes = max(max(round(random(-1, 1)), 0), (int)random(-1 * connections.size()/50, connections.size()/100));
    int newConnections = max(max(round(random(-1, 1)), 0), (int)random(-1 * connections.size() / 5, connections.size() / 5));
    for (int i = 0; i < newNodes; i++) {
      addNode();
    }
    for (int i = 0; i < newConnections; i++) {
      addConnection(true);
    }
    mutateRandomWeights((int)random(0, connections.size() / 2));
  }

  int findIndexOfConnection(int inno) {
    for (int i = 0; i < connections.size(); i++) {
      if (connections.get(i).innoNo == inno)
        return i;
    }
    return -1;
  }

  void dispNetwork() { //node width = 4
    int[] displayed = new int[layers];
    for (int i = 0; i < nodes.size(); i++) {
      if (nodeOutputs.get(i) != null) {
        fill(128 + 127 * nodeOutputs.get(i));
      }
      noStroke();
      rect(height + displayed[nodes.get(i).layer] * 4, 0 + nodes.get(i).layer * 4, 4, 4);
      displayed[nodes.get(i).layer]++;
    }
  }
}
