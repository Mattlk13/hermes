package src.hermes;

import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Collection;
import java.util.ArrayList;

import com.illposed.osc.*;
import oscP5.*;
import netP5.*;
import processing.core.*;

/**
 * Listens for and sends OSC, mouse, and keyboard messages
 * Tells subscribers of a specific type of message when one is received
 * and passes on information stored in message to subscriber
 * @author Ryan
 *
 */
public class PostOffice {
	
	//If illposed.osc is used instead of oscP5
	//OSCPorts for listening and receiving
	OSCPortIn _receive;
	OSCPortOut _send;
	
	ArrayList<Subscription> _subscriptions; 
	
	//Holder class to hold subscriptions
	class Subscription {
		Collection _group;
		MessageHandler _handler;
		
		protected Subscription(Collection group, MessageHandler handler) {
			group = _group;
			handler = _handler;
		}
	}
	
	//Fields containing subscribing Beings
	ArrayList<Being> _keySubscribed;
	ArrayList<Being> _mouseSubscribed;
	ArrayList<Being> _oscSubscribed;
	
	
	//Constructors for illposed
	//Constructor that sends out to default location on localhost
	public PostOffice(int portIn) {
		try {
			_receive = new OSCPortIn(portIn);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			_send = new OSCPortOut();
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	//Constructor that defines location to send to on localhost
	public PostOffice(int portIn, int portOut) {
		try {
			_receive = new OSCPortIn(portIn);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			_send = new OSCPortOut(InetAddress.getLocalHost(),portOut);
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	//Constructor for PostOffice that sends messages to non-local address
	public PostOffice(int portIn, int portOut, String netAddress) {
		try {
			_receive = new OSCPortIn(portIn);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			_send = new OSCPortOut(InetAddress.getByName(netAddress), portOut);
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * Registers a subscription
	 * @param g
	 * @param handler
	 * @param check
	 */
	public void registerSubscription(Collection g, MessageHandler handler, Message check) {
		_subscriptions.add(new Subscription(g,handler));
	}
	
	
	
	
	
	//Sends key presses to subscribing Beings
	void handleKeyPress(char keyPressed) {
		
	}

	//Sends mouse clicks to subscribing Beings
	void handleMouseClick(Point clickLocation) {
		
	}

	//Sends osc messages to subscribing Beings
	//Q: how will we internally represent OSC messages?
	void handleOSC(Message recievedMessage) {
		
	}

	//Registers Group of Being for keyboard subscription
	void registerKeySubscribe(Collection<Being> g) {
		_keySubscribed.addAll(g);
	}

	//Registers Group of Being for mouse subscription
	void registerMouseSubscribe(Collection<Being> g) {
		
	}

	//Registers Group of Being for osc subscription
	void registerOSCSubscribe(Collection<Being> g) {
		
	}
	
	//Runs Post Office
	//Waits for events, and adds them to queue for handling
	//Does not handle events while a world update loop is running
	void run() {
		
	}
}
