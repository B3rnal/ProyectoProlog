import java.util.Random;
import java.util.Iterator;
import java.util.stream.*;
import rx.*;
import rx.observers.*;
import rx.observables.*;

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

class Client extends Subscriber<Integer> implements Informer{
   private static int counter=0;
   private String name;
   private int times=1;
   public String getName(){return this.name;}
   
   
   private String takeAName(){
      return this.name="A Being-"+(counter++)+"-"+probability;
   }
   public Client(){
     
     takeAName();
	 inform("I'm alive", ":-)");
	 
   }
   private Random r= new Random();
   private int probability=r.nextInt(100);
   
   public void onNext(Integer arg){
      int k = arg;
      inform(master.getName(), "sends me a "+k);
	  if(k>=probability){
		  inform("Sh...t", "Ouuuugh", " I'm dying...:");
		  getOut();
		  inform(" I finally die... :-(");			  
	  }else{
	    String close = ((probability-k)<10)?"That was close, but":"";
		inform(close, "SAFE!!", Integer.toString(times++), "times", ":-)");
	  }
  
   }
   public void getOut(){
     unsubscribe();
	 this.master.decObservers();
   }
   public void onError(Throwable e){
   }
   public void onCompleted(){
   }
   private Service master=null;
   public void setMaster(Service master){
     if(this.master == null)
      this.master = master;
   }
}
/*
class Destiny implements Iterable<Integer>{
   static class IntIter implements Iterator<Integer>{
      private next=0;
      public Integer next(){
	     return next++;
	  }
	  public boolean hasNext(){return false;}
	  public void remove() throws Exception{
	  }
   }
   public Iterator<Integer> iterator(){
      return new IntIter();
   }
}
*/
class IntIter implements Iterator<Integer>{
      private final int NONE=-1;
      private Random r= new Random();
      private int probability=95;
      Service owner;
      public IntIter(Service owner){
	     this.owner = owner;
	  }
	  @Override
      public Integer next(){
	     int k = r.nextInt(100);
		 if(k<probability){
			  owner.inform("Bang!. All less than", Integer.toString(k), "beings MUST die");  
	     } else k=NONE;
	     return k;
	  }
	  public boolean hasNext(){return owner.shouldIRest();}
	  public void remove(){
	  }
 }
class Service implements Iterable<Integer>,  Informer{
   
   private String name="The Universe";
   public String getName(){return this.name;}
   private int observers=-1;
   public int getNumOfObservers(){return this.observers;}
   public void setNumOfObservers(int n){this.observers=n;}
   int countObservers(){return this.observers;}
   public void incObservers(){
     ++this.observers;
   }
   public void decObservers(){this.observers--;}
   public boolean shouldIRest(){
       if(this.observers<0) return false;
	   
	   if(countObservers()==0){
		 inform("Now I will rest in peace, too");
		 return false;
	   } else{
	     inform("Still some creatures outthere: "+this.observers);
	     think();
	     return true;
	   }
   }
   public void collapse(){
      inform("I got "+this.observers, "creatures :-)");
   }
   public IntIter iterator(){ 
		  return new IntIter(this);
	  
   }
   
   
}
public class TestNFlixObserver{
   static int MAX=2;
   public static void splash(){
     System.out.println("Testing Observer");
   }
   public static void main(String[] args){
      splash();
      Service g = new Service();
	  Observable<Integer> s = Observable.from(g);
	  ConnectableObservable<Integer> c = 
	     s.doOnSubscribe(()->{})
	      .doOnUnsubscribe(()->{})
	      .doOnCompleted(()->{g.collapse();})
		  .publish();
	  IntStream.rangeClosed(1, MAX)
	           .forEach((i)->{
			      Client b = new Client();
				  b.setMaster(g);
	              c.subscribe(b);
	           });
	  g.setNumOfObservers(MAX);
	  Thread game = new Thread(()->{c.connect();});
	  game.start();
	  
   }
}