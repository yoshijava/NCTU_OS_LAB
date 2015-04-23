extern void show(unsigned int,unsigned int);

void saveSSSP(unsigned short, unsigned short);
void iret(unsigned short, unsigned short);
void saveChar(unsigned short);
void setScrIndex(int);
void moveUp();

unsigned short ss, sp;
unsigned char monitor[4][4096];

unsigned int cursor=0;
unsigned short character;
int isFirstTime=1;
int scr=0;
int x[4],y[4];

int mymain(void) {
	unsigned char attr=0x0E;
	unsigned int i=0,j=0,k=0;
	unsigned int c=(unsigned char)character;

	if(isFirstTime==1) {
		isFirstTime=0;
		for(i=0; i<4096; i+=2) {
			for(j=0; j<4; j++) {
				monitor[j][i+1]=attr;
				attr++;
				if(attr>0x0f) {
					attr=0x01;
				}
				monitor[j][i]=' ';
			}
		}
		for(i=0; i<4; i++) {
			x[i]=0;
			y[i]=0;
		}
	}
	else if(c==0) {
		for(i=0; i<4096; i+=2) {
			c=monitor[scr][i+1];
			c<<=8;
			c|=monitor[scr][i];
			show(i,c);
		}
		iret(ss,sp);	
	}
	else if(c=='\n') {
		y[scr]++;
		if(y[scr]>24) {
			moveUp();
			y[scr]=24;
		}
	}
	else if(c=='\r') {
		x[scr]=0;
	}
	else if(c=='\b') {
		if(x[scr]==0 && y[scr]==0) {
		
		}
		else if(x[scr]==0) {
			x[scr]=79;
			y[scr]--;
		}
		else {
			x[scr]--;
		}
	}
	else {
		x[scr]++;
		if(x[scr]>79) {
			y[scr]++;
			x[scr]=0;
			if(y[scr]>24) {
				moveUp();
				y[scr]=24;
			}	
		}
		monitor[scr][y[scr]*160+x[scr]*2]=c;
	}
	/*update();*/
	for(i=0; i<4096; i+=2) {
		c=monitor[scr][i+1];
		c<<=8;
		c|=monitor[scr][i];
		show(i,c);
	}
	iret(ss,sp);
}

void moveUp() {
	unsigned int i,j;
	for(i=0; i<24; i++) {
		for(j=0; j<80; j++) {
			monitor[scr][i*160+j*2]=monitor[scr][(i+1)*160+j*2];
		}
	}
	for(j=0; j<80; j++) {
		monitor[scr][24*160+j*2]=' ';
	}
}

void setScrIndex(int i) {
	scr = i-1;
}

void saveChar(unsigned short cc) {
	character=cc;
}

void saveSSSP(unsigned short ess, unsigned short esp) {
	sp = esp;
	ss = ess;
	return;
}
