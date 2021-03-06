class Person {
  private int state = 0; //0 = healthy; 1 = infected; 2 = recovered; 3 = deceased; 4 = incubation
  private float rot, dr, x, y, p_d, p_i, p_a;
  private int t_incubated, t_infected = 0;
  
  public Person(int x_min, int x_max, int y_min, int y_max){
    this.p_i = 0.2;
    this.p_d = 0.1;
    this.p_a = 0.05;
    this.rot = random(0, 360);
    this.dr = random(10, 20);
    this.x = random(x_min, x_max);
    this.y = random(y_min, y_max);
  }
  
  void gen_aerosol(Env e){
    float r = random(0, 1); 
    if(r < p_a && do_aerosols) {
      Aerosol a = new Aerosol(this.x, this.y);
      e.aerosols.add(a);
    }
  }
  
  //infect individual using set probability
  void p_infect(){ 
    float r = random(0, 1); 
    if(r < p_i){ this.state = 4; }
  }
  
  void a_infect(Aerosol a){
    boolean is_in_a = pow(this.x - a.x, 2) + pow(this.y - a.y, 2) < pow(a.radius, 2);
    if(is_in_a){ this.p_infect(); }
  }
  
  void setState(int state){
    this.state = state;
  }
  
  int getState(){
    return this.state;
  }
  
  //set individual to recovered or deceased based on set probability
  void p_remove(){
    float r = random(0, 1);
    if(r < p_d){ this.state = 3; } else { this.state = 2; }
  }
  
  //infect all healthy neighbors within the set infection radius
  void infect_neighbors(Env w){
    for(Person p : w.people){
        if(p.getState() == 0) {
          float distance = sqrt(pow(p.x - this.x, 2) + pow(p.y - this.y, 2));
          if(distance < infect_radius){ p.p_infect(); }
        }
     }
  }
  
  void p_travel(Env from, Env to){
    float r = random(0, 1);
    if(this.state != 3 && r < 0.1){ this.move(from, to); }
  }
  
  void move(Env from, Env to){
    to.people.add(this);
    from.people.remove(this);
    x = lerp(x, to.x_min + (to.side / 2), 1);
    y = lerp(y, to.y_min + (to.side / 2), 1);
  }
  
  void update(Env w){
    if(state != 3){
      rot = rot + random(-10, 10);
      float target_x = x + dr * cos(radians(rot));
      float target_y = y + dr * sin(radians(rot));
      x = lerp(x, target_x, 0.1);
      y = lerp(y, target_y, 0.1);
    }  
    
    if(!w.is_in_world(this)){
      w.constrain_to_world(this);
    }
    
    if(this.state == 1){ this.gen_aerosol(w); }
  }
  
  void update_state(){
    switch(state){
      case 4:
        t_incubated = t_incubated + 1;
        if(t_incubated > 5 * tDay) {
          this.state = 1;
        }
        break;
      case 1:
        t_infected = t_infected + 1;
        if(t_infected > 14 * tDay) {
          this.p_remove();
        }
      default:
        break;
    }
  }
  
  void show(){
    if(state == 0){
       stroke(59, 168, 82);
       fill(59, 168, 82); 
    } else if(state == 1){
       stroke(212, 57, 73);
       fill(212, 57, 73);
    } else if(state == 4){
       stroke(220, 224, 92);
       fill(220, 224, 92);
    }  else if(state == 2){
       stroke(100);
       fill(100);
    } else if(state == 3){
       stroke(70);
       fill(70);
    }
    ellipse(x, y, 7, 7);
  }
}
