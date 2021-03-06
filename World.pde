class World{
  ArrayList<Env> envs = new ArrayList<Env>();
  Env quarantine;
  
  World(Env quarantine, Env ...envs){
    this.quarantine = quarantine;
    for(Env e : envs){
      this.envs.add(e);
      e.gen_pop();
    }
  }
  
  void show(){
    noFill();
    stroke(200);
    for(Env e : envs){
      e.show();
    }
    quarantine.show();
  }
  
  void update(){
    for(Env e : envs){
      e.update();
    }
    quarantine.update();
  } 
  
  //return random environment
  Env rand_env(){
    int i = (int)random(0, envs.size());
    return this.envs.get(i);
  }
  
  //return random environment that is not e
  Env rand_env(Env e){
    while(true){
      int i = (int)random(0, envs.size());
      if(this.envs.get(i) != e) {  return this.envs.get(i); }
    }
  }
  
  void travel(){
    if(this.envs.size() > 1){
      Env e = this.rand_env();
      int i = (int)random(0, e.people.size());
      e.people.get(i).p_travel(e, this.rand_env(e));
    }
  }
  
  void move_to_quarantine(){
    for(Env e : envs){
      for(int i = 0; i < e.people.size(); i++){
        //move infected people to quarantine after q_days * tDay timesteps
        if (e.people.get(i).t_infected > q_days * tDay){
          e.people.get(i).move(e, quarantine);
          i = i - 1;
          continue;
        }
      }
    }
  }
  
  void remove_aerosols(){
    for(Env e : envs){
      for(int i = 0; i < e.aerosols.size(); i++){
        if (e.aerosols.get(i).t_alive > a_lifetime){
          e.aerosols.remove(i);
          i = i - 1;
          continue;
        }
      }
    }
  }
  
  void show_people(){
    for(Person p : quarantine.people){
      p.show();
      p.update(quarantine);
      p.update_state();
    }
    for(Env e : envs){
      for(Person p : e.people){
        p.show();
        p.update_state();
      }
      int p_update = round(p_not_sd * e.people.size());
      for(int i = 0; i < p_update; i++){
        e.people.get(i).update(e);
      }
    }
  }
  
  void show_aerosols(){
    for(Env e : envs){
      for(Aerosol a : e.aerosols){
        a.show();
        a.update();
      }
    }
  }
  
  int[] getStatistics(){
    int[] total = quarantine.getStatistics();
    for(Env e : envs){
      total = add(total, e.getStatistics());
    }
    return total;
  }
  
  //add two arrays element-wise
  int[] add(int[] first, int[] second){
    int len = first.length < second.length ? first.length : second.length; 
    int[] result = new int[len]; 
    for (int i = 0; i < len; i++) { 
      result[i] = first[i] + second[i]; 
    } 
    return result;
  }
}
