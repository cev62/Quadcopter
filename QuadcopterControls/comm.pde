class Comm extends Thread
{
  
  final static String HOST = "192.168.1.31";
  final static int PORT = 22333;
        
  boolean m_bIsConnected;
  boolean m_bIsSocketInitialized;  // Flag is set if the current socket object still needs to be closed.
  long m_recvTimer;
  Model m_model;
  Socket m_socket;
  PrintWriter m_socketOut;
  BufferedReader m_socketIn;
  
  Comm(Model model){
    this.m_model = model;
    m_bIsConnected = false;
    m_recvTimer = 0;
    start(); // Start thread
  }
  
  /*
   * This implements a custom multi-bit serial protocol. Here are the particulars
   *
   * When a machine wants to send a message, it begins by sending a request.
   * A request is a byte containing 128 + [number of bytes of information contained in the message]
   * A request may be sent repeatedly to ensure it is received.
   *
   * Once the other machine receives the request, the receiving machine will clear its serial buffer  
   * in preparation for receiving the rest of the message.
   * It will then ack (acknowlege) the request by sending a single byte containing 128.
   *
   * Once the sending machine receives the ack, it stops sending requests and begins sending the main message.
   * Data in the main message must be < 128, any byte greater than 128 will be interpreted as either a request or an ack.
   *
   */
   
  // This thread just tries to connect over the socket
  public void run() {
    while(true)
    {
      if (!m_bIsConnected)
      {
        // Socket is DISCONNECTED. Try to establish connection.
        // Attempt to make connection
        try
        {
            if (m_bIsSocketInitialized)
            {
              m_socket.close();
              m_bIsSocketInitialized = false;
            }
            System.out.print("Attempting to connect...");
            m_socket = new Socket(Comm.HOST, Comm.PORT);
            m_bIsSocketInitialized = true;
            m_bIsConnected = true;
            m_socketOut = new PrintWriter(m_socket.getOutputStream(), true);
            m_socketIn = new BufferedReader(new InputStreamReader(m_socket.getInputStream()));
            System.out.println("Connection made!");
        } catch (Exception e) {
            m_bIsConnected = false;
            System.err.println("Can't connect to host " + HOST + ":" + PORT);
        }
      }
      else
      {
        // Socket is CONNECTED. Send/Receive data.
        try
        {
          // This will wait untill a message is received, then it will send a message back.
          receiveMessage();
          sendMessage();
        }
        catch (Exception e)
        {
          m_bIsConnected = false;
          System.err.println("ERROR: Communication Failed...");
        }
      }
    }
  }
 
  void update(){
    if (millis() - m_recvTimer > 1050)
    {
      // Timed out
      m_bIsConnected = false;
    }
  }
  
  void receiveMessage() throws Exception
  {
    String msg = m_socketIn.readLine();
    System.out.println("From pi: " + msg);
    if (msg != null)
    {
      m_recvTimer = millis();
    }
  }
  
  void sendMessage() throws Exception
  {
    /*serial.write(convertFloatTo7B2C((float)model.xInput));
    dataOut = convertFloatTo7B2C((float)model.xInput);
    serial.write(convertFloatTo7B2C((float)model.yInput));
    serial.write(convertFloatTo7B2C((float)model.zInput));
    serial.write(convertFloatTo7B2C((float)model.turnInput));*/
    
    String msg = "";
    synchronized(m_model)
    {
      msg += convertFloatToInt((float)model.xInput);
      msg += ",";
      msg += convertFloatToInt((float)model.yInput);
      msg += ",";
      msg += convertFloatToInt((float)model.zInput);
      msg += ",";
      msg += convertFloatToInt((float)model.turnInput);
      msg += "$";
    }
    m_socketOut.println(msg);
    
  }
  
  // Converts a float from [-1.0,1.0] to 7-bit 2's compliment [-64,63]
  int convertFloatTo7B2C(float input){
    int output = (int)map(input, -1.0, 1.0, -64.0, 63.0);
    if(output < 0){
      output += 128;
    }
    return output;
  }
  
  // Converts a float from [-1.0,1.0] to an unsigned int [0,255]
  int convertFloatToInt(float input){
    int output = (int)map(input, -1.0, 1.0, 0.0, 255.0);
    return output;
  }
  
  // Converts a 7-bit 2's compliment [-64,63] to an int
  int convert7B2CToInt(int input){
    if(input < 64){
      return input;
    }
    else{
      return input - 128;
    }
  }
  
  void toggleConnection()
  {
      // @TODO implement
  }
  
  void loadInputIntoModel()
  {
    
  }
  
  boolean isConnected() { return m_bIsConnected; }
  
}
