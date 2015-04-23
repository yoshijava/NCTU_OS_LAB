extern void initHeadTail();
extern int getHead();
extern int getTail();
extern void setTail(int);
extern void enableKey();
extern void disableKey();
extern int getScanCode();
extern void setKeyCode(int);
extern void setActiveShell(int);
extern void eoi();
void saveSSSP(unsigned short, unsigned short);

unsigned char asciiTab[256];
int firstTime=1;
int isCtrlDown=0;
unsigned short ss, sp;

void initTab();
int lookupAscii(int);


int mymain(void) {
	unsigned int code=0;
	unsigned char head=0, tail=0;
	unsigned char scanCode=0, asciiCode=0;
	disableKey();
	if(firstTime==1) {
		initHeadTail();
		initTab();
		firstTime=0;
	}
	scanCode=getScanCode();
	asciiCode=lookupAscii(scanCode);
	if(asciiCode==0) { /* not printable */
		if(scanCode==0x1D) {	/* check if ctrl is pressed or not */
			isCtrlDown=1;
		}
		else if(scanCode==0x9d) {
			isCtrlDown=0;
		}
	}
	if(scanCode>=0x3b && scanCode<=0x3e && isCtrlDown==1) {
		setActiveShell((scanCode-0x3b)+1);
	}
	code= scanCode;
	code<<=8;
	code|=asciiCode;
	head=getHead();
	tail=getTail();
	if(!((tail+2)==head || (head==0x1e && tail==0x3c)) ) { /* not full */
		setKeyCode(code);
		if(tail==0x3C) {
			setTail(0x1e);
		}
		else {
			setTail(tail+2);
		}
	}
	enableKey();
	eoi(ss,sp);
}

void initTab() {
	int i=0;
	char Q2P[]={'q','w','e','r','t','y','u','i','o','p'};
	char A2L[]={'a','s','d','f','g','h','j','k','l',':'};
	char Z2M[]={'z','x','c','v','b','n','m'};
	for(i=0; i<256; i++) {
		asciiTab[i]=0;
	}
	for(i=0x02; i<0x0b; i++) {
		asciiTab[i]=i-0x02+'1';
	}
	asciiTab[0x0b]='0';
	for(i=0x10; i<=0x19; i++) {
		asciiTab[i]=Q2P[i-0x10];
	}
	for(i=0x1E; i<=0x27; i++) {
		asciiTab[i]=A2L[i-0x1E];
	}
	for(i=0x2C; i<=0x32; i++) {
		asciiTab[i]=Z2M[i-0x2c];
	}
	asciiTab[0x1C]=0x0d;	/* enter */
	asciiTab[0x0E]=0x08;	/* backspace */
	asciiTab[0x39]=' ';
}

int lookupAscii(int scanCode) {
	return asciiTab[scanCode];
}

void saveSSSP(unsigned short ess, unsigned short esp) {
	sp = esp;
	ss = ess;
	return;
}