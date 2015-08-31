import processing.serial.*;

PFont font;
Serial myPort;
PrintWriter calcdata;
int y;
int mon;
int d;
int h;
int m;
int s;
int s_previous;
int m_previous;
int h_previous;
int num_pump = 6;	// number of pump used
int num_data = 2 * num_pump;	// maximum number of data sent from arduino
int[] data_arduino = new int[num_data];	// data from arduino (array number =  0 - (num_data -1))
int[] duration = new int[num_pump + 1];	// duration of reflectance of pump No. i
float[] distance = new float[num_pump + 1];	// distance from reflector of pump No. i
String pctime;

void setup(){
	y = year();
	mon = month();
	d = day();
	String date = nf(y, 2) + nf(mon, 2) + nf(d, 2);
	size(490, 210);	// create processing window
//	frameRate(1);
	font = loadFont("Calibri-24.vlw");
	textFont(font);
	textAlign(LEFT);
	myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600);	// write the name of the port connected to arduino. e.g. Mac ... "/dev/cu.usbmodem1411", Windows ... "COM4".
	myPort.buffer(100);	// create serial buffer which is large enough to store data 
	calcdata = createWriter(date + "calcdata.txt");
	myPort.clear();
}

void draw(){
	int i;
	int num;
	num = myPort.available();
	y = year();
	mon = month();
	d = day();
	h = hour();
	m = minute();
	s = second();
	background(0);	// color of processing window
	pctime = getpctime();
	if(myPort.available() >= num_data){
		println(num);
		for(i = 0; i < num_data; i++){
			data_arduino[i] = myPort.read();
		}
		myPort.clear();
		for(i = 1; i <= num_pump; i++){
			duration[i] = (data_arduino[2 * (i - 1)] << 8) | data_arduino[2 * i - 1];
		    distance[i] = duration[i] / 2;
		    distance[i] = distance[i] * 340 * 100 / 1000000; // ultrasonic speed is 340m/s = 34000cm/s = 0.034cm/us 
		}
	    textoutputcalc(calcdata, duration, distance);
	    println("serial success");
	}
	if(s != s_previous){
		myPort.clear();
		myPort.write(h);
		myPort.write(m);
		myPort.write(s);
	}
	h_previous = h;
	m_previous = m;
	s_previous = s;
	display(pctime, duration, distance);
}

void textoutputcalc(PrintWriter _textdata, int[] _duration, float[] _distance){
	int i;
	_textdata.print(y + "," + mon + "," + d + "," + h + "," + m + "," + s);
	for(i = 1; i <= num_pump; i++){
		_textdata.print("," + _duration[i]);
	}
	for(i = 1; i <= num_pump; i++){
		_textdata.print("," + _distance[i]);
	}
	_textdata.println("");
}

String getpctime(){
	String _pctime;
	_pctime = nf(h, 2) + ":" + nf(m, 2) + ":" + nf(s, 2);
	return _pctime;
}

void display(String _pctime, int[] _duration, float[] _distance){
	int i;
	text("PC time", 10, 20);
	text(_pctime, 130, 20);
	text("pump No.", 10, 60);
	text("duration", 130, 60);
	text("distance", 230, 60);
	for(i = 1; i <= 6; i++){
		text(i, 10, 80 + 20 * (i - 1));
		text(_duration[i], 130, 80 + 20 * (i - 1));
		text(_distance[i], 230, 80 + 20 * (i - 1));
	}
}

void mousePressed(){
	myPort.clear();
	calcdata.flush();
	calcdata.close();
	exit();
}


