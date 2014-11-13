
import rx.Observable;
import rx.Observer;
import rx.functions.Action1;
import rx.functions.Func2;
 

public class HelloWorld {
     
    private Observable<String> observable;
    private Exception thrown;
    String[] source;
	
	public HelloWorld(String[] source){
	   this.source = source;
	   before();
	}
    
    public void before() {
        observable = Observable.from(source);
    }
 
    
    public  void test1() {
        System.out.println("test1 starts");
        observable.reduce( new Func2<String, String, String>() {            
            public String call(String t1, String t2) {
                return t1 + " " + t2;
            }
        }).subscribe(new Action1<String>() {
            public void call(String s) {
                String actual = s + "!";
                System.out.println(actual);
            }
        });
    }    
     
   
    public  void test2() throws Exception {
	    System.out.println("test2 starts");
        observable.subscribe(new Observer<String>() {
            StringBuilder buf = new StringBuilder();
     
            public void onCompleted() {
			    System.out.println("completed");
                try {
                    String actual = buf.append("!").toString();
                   
                } catch (Throwable e) {
                    onError(e);
                }
            }
 
            public void onError(Throwable e){
                thrown = new RuntimeException(e.getMessage(),e);
            }
 
            public void onNext(String args) {
			    System.out.println("next->"+args);
                buf.append(args).append(" ");                
            }
        });
         
        if(null != thrown){
            throw thrown;
        }        
    }
	public static void main(String... args) throws Exception{
	   if (args.length==0) args = new String[]{"Hola", "Mundo"};
	   HelloWorld me = new HelloWorld(args);
	   me.test1();
	   HelloWorld me2 = new HelloWorld(new String[]{"x", "y"});
	   me2.test2();
	}
}