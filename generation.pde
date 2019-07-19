class generation {
  int population;
  ArrayList<genome> genomes;
  ArrayList<ArrayList<Integer>> species;
  int showing;

  generation(int population, boolean populate) {
    println("Generating....");
    this.population = population;
    genomes = new ArrayList<genome>();
    species = new ArrayList<ArrayList<Integer>>();
    if (populate) {
      for (int i = 0; i < population; i++) {
        genomes.add(new genome(numInputs, numOutputs, i));
        println("Genome " + i + " created.");
      }
    }
    showing = 0;
  }

  generation(generation g) {
    genomes = new ArrayList<genome>(g.genomes);
    species = new ArrayList<ArrayList<Integer>>(g.species);
    population = g.population;
    showing = 0;
  }

  void updateToCompletion() {
    while (everyoneDead() == false) {
      updateAll();
    }
  }

  void updateAll() {
    for (genome g : genomes) {
      g.update();
    }
    if (!warpSpeed)
      showOne();
  }

  void showOne() {
    if (!everyoneDead()) {
      if (genomes.get(showing).g.dead) {
        showing = indexOfMaxScore();
      }
      genomes.get(showing).g.show();
      genomes.get(showing).dispNetwork();
    }
  }

  boolean everyoneDead() {
    for (genome g : genomes) {
      if (g.g.dead == false) {
        return false;
      }
    }
    return true;
  }

  generation nextGen() {
    generation g = new generation(population, false);
    speciate();
    int[] children = allocateChildren();
    for (int i = 0; i < children.length; i++) {
      float[] speciesFitness = speciesFitness(i);
      float medianFitness = median(speciesFitness);
      float maxFitness = max(speciesFitness);
      for (int j = 0; j < species.get(i).size(); j++) {
        if (genomes.get(species.get(i).get(j)).fitness() < medianFitness) {
          species.get(i).remove(j);
          j--;
        }
      }
      for (int j = 0; j < children[i]; j++) {
        int geno1 = (int)random(species.get(i).size());
        while (speciesFitness[geno1] < random(maxFitness)) {
          geno1 = (int)random(species.get(i).size());
        }
        int geno2 = (int)random(species.get(i).size());
        while (speciesFitness[geno2] < random(maxFitness)) {
          geno2 = (int)random(species.get(i).size());
        }
        if (genomes.get(species.get(i).get(geno1)).fitness() > genomes.get(species.get(i).get(geno2)).fitness()) {
          g.genomes.add(new genome(genomes.get(species.get(i).get(geno1))));
          g.genomes.get(g.genomes.size() - 1).crossover(genomes.get(species.get(i).get(geno2)));
        } else {
          g.genomes.add(new genome(genomes.get(species.get(i).get(geno2))));
          g.genomes.get(g.genomes.size() - 1).crossover(genomes.get(species.get(i).get(geno1)));
        }
      }
    }
    return g;
  }

  void speciate() {
    for (int i = 0; i < genomes.size(); i++) {
      boolean speciated = false;
      for (ArrayList<Integer> a : species) {
        if (genomes.get(i).compatibilityDistance(genomes.get(a.get(0))) < 0.5) {
          a.add(i);
          speciated = true;
          break;
        }
      }
      if (speciated == false) {
        species.add(new ArrayList<Integer>());
        species.get(species.size() - 1).add(i);
      }
    }
  }

  int[] allocateChildren() {
    int[] children = new int[species.size()];
    float[] asf = avgSpeciesFitness();
    float totalFitness = sumArray(asf);
    int allocated = 0;
    for (int i = 0; i < children.length; i++) {
      children[i] = floor(asf[i]/totalFitness*population);
      allocated += children[i];
    }
    children[indexOfMaxValue(asf)] += population - allocated;
    return children;
  }

  float[] avgSpeciesFitness() {
    float[] asf = new float[species.size()];
    for (int i = 0; i < asf.length; i++) {
      for (Integer j : species.get(i)) {
        asf[i] += genomes.get(j).fitness();
      }
      asf[i] /= species.get(i).size();
    }
    return asf;
  }

  float[] speciesFitness(int speciesID) {
    float[] sf = new float[species.get(speciesID).size()];
    for (int i = 0; i < sf.length; i++) {
      sf[i] = genomes.get(species.get(speciesID).get(i)).fitness();
    }
    return sf;
  }

  float sumArray(float[] arr) {
    float sum = 0;
    for (float f : arr) {
      sum += f;
    }
    return sum;
  }

  int indexOfMaxValue(float[] arr) {
    int index = 0;
    for (int i = 0; i < arr.length; i++) {
      if (arr[i] > arr[index]) {
        index = i;
      }
    }
    return index;
  }

  float median(float[] arr) {
    float[] temparr = Arrays.copyOf(arr, arr.length);
    Arrays.sort(temparr);

    if (temparr.length % 2 == 0) {
      return (float)(temparr[(temparr.length - 1) / 2] + temparr[temparr.length / 2]) / 2.0;
    }
    return (float)temparr[temparr.length/2];
  }

  int indexOfMaxScore() {
    int[] scores = getScores();
    int index = -1;
    for (int i = 0; i < scores.length; i++) {
      if (index == -1 && genomes.get(i).g.dead == false) {
        index = i;
      }
      if (genomes.get(i).g.dead == false && scores[i] > scores[index]) {
        index = i;
      }
    }
    return index;
  }

  int[] getScores() {
    int[] scores = new int[genomes.size()];
    for (int i = 0; i < scores.length; i++) {
      scores[i] = genomes.get(i).g.length - genomes.get(i).g.baseLength;
    }
    return scores;
  }
}
