extern void putchar(char);
extern char getchar();
extern int checkKeystroke();
extern void readSector(short,short,short,short,short,short); /* readSector(C,H,S,Length,Segment,Offset) */
extern void yield();
extern void notifyScheduler(int);
extern int disassemble(int,int);
extern int readHeader(int);
extern int getActiveShell();
extern int getShellID();
extern void setUsedAsm(unsigned int);
extern unsigned int getUsedAsm();

void handleCmd(char*);
int indexOf(char*,char,int);
void prompt(char*);
void printstr(char*);
void printstrln(char*);
void printint(unsigned int);
void alloc(char*);
void dealloc(char*);
void dump();
void run(char*);
void u(char*);
int parseInt(char*);
int getLength(char*);
void markMemory(char*, unsigned int);
int demandPage(int);
int parseHex(char*);
void printHex(unsigned int);
void setUsed(int,unsigned int);
int getUsed(int);


int mymain()
{
	int i=0;
	char *str = "Yoshi:>";
	for(; i<16; i++) {
		setUsed(i,0);
	}
    putchar('\n');
    putchar('\n');
	printstr(str);
	prompt(str);
    return 0;
}

void prompt(char* promptStr) {
	char cmd[80];
	int count=0;	
	char c=0;
	for(; count<80; count++) {
		cmd[count]='\0';
	}
	count=0;
	while(1) {
		/*
		while(checkKeystroke()==0) {
			for(i=0; i<1000; i++);
    	}
    	*/
    	while(getActiveShell()!=getShellID()) {
			yield();
    	}
    	c=getchar();
    	if(c==0) {
			putchar(c);
			continue;
		}
    	if(count>=80) {
    		printstrln("\n\rCommand too long.");
    		printstr(promptStr);
    		count=0;
    		continue;
    	}
    	cmd[count]=c;
		count++;
    	if(c==13) {
    		cmd[--count]='\0';
    		printstrln("");
	    	handleCmd(cmd);
	    	printstrln("");
	    	printstr(promptStr);
	    	count=0;
	    }
	    else if(c=='\b') {
	    	putchar('\b');
	    	putchar(' ');
	    	putchar('\b');
	    	cmd[--count]='\0';
	    	cmd[--count]='\0';
	    }
	    else {
	    	putchar(c);
	    }
	}
}

void handleCmd(char *cmd) {
	if(startWith(cmd,"alloc")) {
		alloc(cmd);
	}
	else if(startWith(cmd,"dealloc")) {
		dealloc(cmd);
	}
	else if(startWith(cmd,"dump") || startWith(cmd,"print")) {
		dump();
	}
	else if(startWith(cmd,"run")) {
		run(cmd);
	}
	else if(startWith(cmd,"u")) {
		u(cmd);
	}
	else {
		printstr("Bad command or filename");
	}
}

void u(char* cmd) {
	unsigned int x=0;
	int segment=0;
	int offset=0;
	char value[5];
	int i=indexOf(cmd,' ',0);
	i=indexOf(cmd,'x', 0)+1;
	while(cmd[i]!=':') {
		value[x++]=cmd[i++];
	}
	value[x]='\0';
	segment=parseHex(value);
	i=indexOf(cmd,'x',i)+1;
	x=0;
	while(cmd[i]!='\0') {
		value[x++]=cmd[i++];
	}
	value[x]='\0';
	offset=parseHex(value);	
	printHex(segment);
	printstr(":");
	printHex(offset);
	printstr("\t");
	x=disassemble(segment,offset);
	printHex(x);
	printstrln("");
}

void markMemory(char* cmd, unsigned int mark) {
	int x=0;
	int size=0;
	int index=0;
	char value[10];
	int i=indexOf(cmd,' ', 0)+1;
	int j=indexOf(cmd,' ', i);
	for(x=0; x+i<j; x++) {
		value[x]=cmd[x+i];
	}
	value[x]='\0';
	index=parseInt(value);
	j++;
	x=0;
	while(cmd[j]!='\0') {
		value[x]=cmd[j];
		x++;
		j++;
	}
	value[x]='\0';
	size=parseInt(value);
	if(index+size-1 > 15) {
		printstr("There is no enough memory.");
		return;
	}
	for(i=index; i<index+size; i++) {
		setUsed(i,mark);
	}
	printstr("Mark ");
	printint(index);
	printstr(" to ");
	printint(index+size-1);
	if(mark==1) {
		printstrln(" as used");
	}
	else {
		printstrln(" as unused");
	}
}

void alloc(char* cmd) {
	markMemory(cmd,1);
}

void dealloc(char* cmd) {
	markMemory(cmd,0);
}

void dump() {
	int i=0;
	printstrln("<Memory Utility>");
	printstr("| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |\n\r|");
	for(i=0; i<16; i++) {
		if(getUsed(i)==1) {
			printstr(" * |");
		}
		else {
			printstr("   |");
		}
	}
}

void run(char* cmd) {
	int x=0;
	int sector=0;
	int size=0;
	int demandIndex=0;
	int segment=0;
	char value[10];
	int i=indexOf(cmd, ' ',0)+1;
	while(cmd[i]!='\0') {
		value[x]=cmd[i];
		x++;
		i++;
	}
	value[x]='\0';
	sector=parseInt(value);
	readSector(0,0,sector,1,0x400,0);
	x=readHeader(3);
	printstr("filesize is ");
	printint(x);
	printstr(" bytes, need ");
	if(x%512==0) {
		size = x/512;
	}
	else {
		size = x/512;
		size++;
	}
	printint(size);
	printstrln(" bucket(s)");
	demandIndex = demandPage(size);
	if(demandIndex==-1) {
		printstrln("No enough free contiguous space.");
	}
	else {
		segment=256; /* 0x0100:0x0000 */
		segment+=2*16*demandIndex; /* 0020 per segment = 512bytes */
		printstr("Allocate ");
		printint(demandIndex);
		printstr(" to ");
		printint(demandIndex+size-1);
		printstrln(" for application");
		printstr("Load to ");
		printHex(segment);
		printstrln(":0x0");
		readSector(0,0,sector,size,segment,0);  /* readSector(C,H,S,Length,Segment,Offset) */
		notifyScheduler(segment);
		if(startWith(cmd,"runb")) {
			printstrln("Background program, does not release memory automatically.");
		}
		else {
			printstr("Release memory from ");
			printint(demandIndex);
			printstr(" to ");
			printint(demandIndex+size-1);
			printstrln(" for application");
			for(x=demandIndex; x<=demandIndex+size-1; x++) {
				setUsed(x,0);
			}
		}
	}
}

int demandPage(int size) {
	int i=0;
	int j=0;
	int freeSpace=0;
	for(i=0; i<16; i++) {
		if(getUsed(i)==1) {
			freeSpace=0;
		}
		else {
			freeSpace++;
		}
		if(freeSpace>=size) {
			for(j=0; j<size; j++) {
				setUsed(i-j,1);
			}
			return i-size+1;
		}
	}
	return -1;
}


int parseInt(char* cmd) {
	int length=getLength(cmd);
	int i=length-1;
	int value=0;
	int b=0;
	for(; i>=0; i--) {
		b = cmd[i]-'0';
		value+= b * pow(10,(length-i-1));
	}
	return value;
}

int getLength(char* cmd) {
	int i=0;
	while(cmd[i]!='\0') {
		i++;
	}
	return i;
}

int startWith(char* cmd, char* pattern) {
	int i=0;
	while(pattern[i]!='\0') {
		if(pattern[i]!=cmd[i]) {
			return 0;
		}
		i++;
	}
	return 1;
}

int indexOf(char *str, char c, int start) {
	int index=start;
	while(str[index]!='\0') {
		if(str[index]==c) {
			return index;
		}
		index++;
	}
	return -1;
}

int pow(int base, int e) {
	int ans=1;
	int i=0;
	if(e==0) {
		return 1;
	}
	for(i=0; i<e; i++) {
		ans*=base;
	}
	return ans;
}

int getUsed(int i) {
	unsigned int bitmap=getUsedAsm();
	bitmap=bitmap>>i;
	bitmap=0x1 & bitmap;
	return bitmap;
}

void setUsed(int i, unsigned int mark) {
	unsigned int v=1;
	unsigned int bitmap=getUsedAsm();
	v=v<<i;
	if(mark==0) {
		v=~v;
		bitmap&=v;
	}
	else {
		bitmap|=v;
	}
	setUsedAsm(bitmap);
}

void printstrln(char* str) {
	printstr(str);
	printstr("\n\r");
}

void printstr(char* str) {
	char *p = str;
    while((*p)!='\0') {
        putchar(*p);
        p++;
    }
    return;
}

void printint(unsigned int i) {
    char a[10];
    int x=0;
    int base=10;
    int flag=0;
	if(i==0) {
		putchar('0');
	}
    for(x=0; x<10; x++) {
        a[x]=i%base;
        i/=base;
    }
    for(x=9; x>=0; x--) {
        if(flag==0) {
            if(a[x]!=0) {
                flag=1;
            }
            else {
                continue;
            }
        }
        a[x]=a[x]+'0';
        putchar(a[x]);
    }
    return;
}

int parseHex(char* cmd) {
	int value=0;
	int i=0;
	int base=16;
	int p=0;
	int v=0;
	while(cmd[i]!='\0') {
		i++;
	}
	i--;
	while(i>=0) {
		switch(cmd[i]) {
			case 'A': case 'a': v=10; break;
			case 'B': case 'b': v=11; break;
			case 'C': case 'c': v=12; break;
			case 'D': case 'd': v=13; break;
			case 'E': case 'e': v=14; break;
			case 'F': case 'f': v=15; break;
			default:
				v=cmd[i]-'0';
		}
		value+=v*pow(base,p++);
		i--;
	}
	return value;
}

void printHex(unsigned int i) {
	char s[10];
	int mod=0;
	int k=0;
	printstr("0x");
	if(i==0) {
		putchar('0');
	}
	while(i!=0) {
		mod=i%16;
		i/=16;
		if(mod<10) {
			s[k]='0'+mod;
		}
		else {
			switch(mod) {
				case 10: s[k]='A';break;
				case 11: s[k]='B';break;
				case 12: s[k]='C';break;
				case 13: s[k]='D';break;
				case 14: s[k]='E';break;
				case 15: s[k]='F';break;
			}
		}
		k++;
	}
	s[k]='\0';
	k--;
	while(k>=0) {
		putchar(s[k]);
		k--;
	}
}