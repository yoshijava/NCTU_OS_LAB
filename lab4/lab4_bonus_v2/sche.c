extern void run(unsigned short, unsigned short);
extern void runFirstTime(unsigned short, unsigned short);
extern void cli(void);
extern void sti(void);
extern void out20(void);
extern int getJobNumber();
extern int getSegment();
extern void clearJob();

typedef struct {
	unsigned short ss;
	unsigned short sp;
} JobAtom;

void printstr(char*);
void printint(unsigned int);
void runJob();
int addToTaskQueue(JobAtom);
void saveJob();
void saveSSSP(unsigned short, unsigned short);
void checkJob();
void forceRun();

int runningJob=0;
JobAtom taskQueue[10];
int	firstTimeToRun[10];
int firstTime=1;
int used[10];

unsigned short ss, sp;

/*
	this scheduler cannot depend on stack memory, because all the things will disappear after reentrance
*/

int mymain(void) {
	JobAtom shell;
	int i=0;
	cli();
	/*
	printstr("[Scheduler] Scheduling...\n\r");
	*/
	if(firstTime==1) { /* first time to run this scheduler! */
		firstTime=0;
		for(i=0; i<10; i++) {
			firstTimeToRun[i]=1;
			used[i]=0;
		}
		shell.ss=0x800U;
		shell.sp=0xfff0U;
		addToTaskQueue(shell);
		shell.ss=0x1800U;
		shell.sp=0xfff0U;
		addToTaskQueue(shell);
		shell.ss=0x2800U;
		shell.sp=0xfff0U;
		addToTaskQueue(shell);
		shell.ss=0x3800U;
		shell.sp=0xfff0U;
		addToTaskQueue(shell);
		runJob();
		return;
	}
	saveJob();
	checkJob();
	runJob();
}

void checkJob() {
	JobAtom job;
	int i=0;
	unsigned short deleteSegment;
	if(getJobNumber()==0) {	/* normal case */
		return;
	}
	else if(getJobNumber()==1) { /* add a process */
		job.ss = getSegment();
		job.sp = 0xfff0U;
		i=addToTaskQueue(job);
		/* runningJob = i;	*/
		/* force the new process to be execute first */
		clearJob();
		/* forceRun(i); */
		return;
	}
	else if(getJobNumber()==2) { /* delete a process */
		deleteSegment = getSegment();
		for(i=0; i<10; i++) {
			if(taskQueue[i].ss == deleteSegment) {
				used[i]=0;
				firstTimeToRun[i]=1;
				break;
			}
		}
		clearJob();
		return;
	}
}

void saveSSSP(unsigned short ess, unsigned short esp) {
	sp = esp;
	ss = ess;
	return;
}

void saveJob(void) {
	taskQueue[runningJob].ss = ss;
	taskQueue[runningJob].sp = sp;
		
}

int addToTaskQueue(JobAtom atom) {
	int i=0;
	for(; i<10; i++) {
		if(used[i]==0) {
			taskQueue[i].ss=atom.ss;
			taskQueue[i].sp=atom.sp;
			used[i]=1;
			return i;
		}
	}
	return -1;
}

void runJob(void) {
	JobAtom job;
	runningJob=(1+runningJob)%10; /* next job */
	while(used[runningJob]==0) {
		runningJob=(runningJob+1)%10;
	}
	job=taskQueue[runningJob];
	/* prepare for run */
	if(firstTimeToRun[runningJob]==1) {
		firstTimeToRun[runningJob]=0;
		runFirstTime(job.ss,job.sp); 
	}
	else {
		run(job.ss, job.sp);
	}
}

