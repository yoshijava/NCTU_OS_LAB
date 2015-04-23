extern void show(unsigned int,unsigned int);

void saveSSSP(unsigned short, unsigned short);
void iret(unsigned short, unsigned short);
void saveChar(unsigned short);
void setScrIndex(int);
void moveUp();
void update();

unsigned short ss, sp;
unsigned char screen[4][40][12];
unsigned char monitor[4096];

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
			monitor[i+1]=attr;
			attr++;
			if(attr>0x0f) {
				attr=0x01;
			}
			monitor[i]=' ';
		}
		for(i=0; i<4; i++) {
			x[i]=0;
			y[i]=0;
		}
		for(i=0; i<4; i++) {
			for(j=0; j<40; j++) {
				for(k=0; k<12; k++) {
					screen[i][j][k]=' ';
				}
			}
		}
	}
	else if(c=='\n') {
		y[scr]++;
		if(y[scr]>11) {
			moveUp();
			y[scr]=11;
		}
	}
	else if(c=='\r') {
		x[scr]=0;
	}
	else if(c=='\b') {
		if(x[scr]==0 && y[scr]==0) {
		
		}
		else if(x[scr]==0) {
			x[scr]=39;
			y[scr]--;
		}
		else {
			x[scr]--;
		}
	}
	else {
		x[scr]++;
		if(x[scr]>39) {
			y[scr]++;
			x[scr]=0;
			if(y[scr]>11) {
				moveUp();
				y[scr]=11;
			}	
		}
		screen[scr][x[scr]][y[scr]]=c;
	}
	update();
	iret(ss,sp);
}

void update() {
	unsigned int c;
	unsigned int i,j;
	switch(scr) {
		case 0:
			for(i=0; i<12; i++) {
				for(j=0; j<40; j++) {
					monitor[i*160+j*2]=screen[scr][j][i];
				}
			}
			break;
		case 1:
			for(i=0; i<12; i++) {
				for(j=0; j<40; j++) {
					monitor[i*160+j*2+80]=screen[scr][j][i];
				}
			}
			break;
		case 2:
			for(i=0; i<12; i++) {
				for(j=0; j<40; j++) {
					monitor[i*160+j*2+1920]=screen[scr][j][i];
				}
			}
			break;
		case 3:
			for(i=0; i<12; i++) {
				for(j=0; j<40; j++) {
					monitor[i*160+j*2+2000]=screen[scr][j][i];
				}
			}
			break;
		default:
			break;
	}
	for(i=0; i<4096; i+=2) {
		c=monitor[i+1];
		c<<=8;
		c|=monitor[i];
		show(i,c);
	}
}

void moveUp() {
	unsigned int i,j;
	for(i=0; i<11; i++) {
		for(j=0; j<40; j++) {
			screen[scr][j][i]=screen[scr][j][i+1];
		}
	}
	for(i=0; i<40; i++) {
		screen[scr][i][11]=' ';
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
