import java.util.*;
import java.util.stream.*;

interface Informer{
   String getName();
   default void inform(String... msgs){
      System.out.print("\n"+getName()+" says: ");
      Stream.of(msgs)
	        .forEach((msg)->{System.out.print(msg+ " ");});
	  System.out.println();
	  think();
   }
   default void think(int s){
      try{Thread.sleep(s*1000);}catch(Exception e){}
   }
   default void think(){
      think(1);
   }
}

class Client implements Observer, Informer{
   private static int counter=0;
   private String name;
   private int times=1;
   public String getName(){return this.name;}
   
   public Client(String name){
      this.name=name;
   }
   private String takeAName(){
      return this.name="A Being-"+(counter++)+"-"+probability;
   }
   public Client(){
     takeAName();
	 inform("I'm alive", ":-)");
	 
   }
   private Random r= new Random();
   private int probability=r.nextInt(100);
   
   public void update(Observable o, Object arg){
      int k = (Integer)arg;
      inform(master.getName(), "sends me a "+k);
	  if(k>=probability){
		  inform("Sh...t", "Ouuuugh", " I'm dying...:");
		  o.deleteObserver(this);
		  think(1);
		  inform("I finally die... :-(");			  
	  }else{
	    String close = ((probability-k)<10)?"That was close, but":"";
		inform(close, "SAFE!!", Integer.toString(times++), "times", ":-)");
	  }
  
   }
   private Service master=null;
   public void setMaster(Service master){
     if(this.master == null)
      this.master = master;
   }
}
class Service extends Observable implements Runnable, Informer{
   private Random r= new Random();
   private int probability=95;
   private String name="The Universe";
   public String getName(){return this.name;}
   
   private void letAllOfThemKnow(int k){
      setChanged();
	  notifyObservers(k);
   }
   private boolean shouldIRest(){
       if(countObservers()==0){
		 inform("Now I will rest in peace, too");
		 return true;
	   } else{
	     inform("Still some creatures outthere: "+countObservers());
	     think();
	     return false;
	   }
   }
   public void run(){ 
		while(true){
		   int k = r.nextInt(100);
		   if(k<probability){
			  inform("Bang!. All less than", Integer.toString(k), "beings MUST die");
			  letAllOfThemKnow(k);
		   }
		   if(shouldIRest()) return;
		}
	  
   }
}
public class TestObserver{
   
   static int MAX=5;
   public static void splash(){
     System.out.println("Testing Observer");
   }
   public static void main(String[] args){
      splash();
      Service s = new Service();
	  IntStream.range(0, MAX)
	           .forEach((i)->{
			      Client c = new Client();
				  c.setMaster(s);
	              s.addObserver(c);
	           });
	  s.run();
	  
   }
}