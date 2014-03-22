
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		start,_start
start: _start:
	movw	$0x1234,0x472			# warm boot BIOS flag
  100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
  100006:	00 00                	add    %al,(%eax)
  100008:	fb                   	sti    
  100009:	4f                   	dec    %edi
  10000a:	52                   	push   %edx
  10000b:	e4 66                	in     $0x66,%al

0010000c <_start>:
  10000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
  100013:	34 12 

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
  100015:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(cpu_boot+4096),%esp
  10001a:	bc 00 60 10 00       	mov    $0x106000,%esp

	# now to C code
	call	init
  10001f:	e8 6f 00 00 00       	call   100093 <init>

00100024 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
  100024:	eb fe                	jmp    100024 <spin>
  100026:	90                   	nop
  100027:	90                   	nop

00100028 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100028:	55                   	push   %ebp
  100029:	89 e5                	mov    %esp,%ebp
  10002b:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10002e:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100031:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100034:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100037:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10003a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10003f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100042:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100045:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  10004b:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100050:	74 24                	je     100076 <cpu_cur+0x4e>
  100052:	c7 44 24 0c e0 29 10 	movl   $0x1029e0,0xc(%esp)
  100059:	00 
  10005a:	c7 44 24 08 f6 29 10 	movl   $0x1029f6,0x8(%esp)
  100061:	00 
  100062:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100069:	00 
  10006a:	c7 04 24 0b 2a 10 00 	movl   $0x102a0b,(%esp)
  100071:	e8 ba 02 00 00       	call   100330 <debug_panic>
	return c;
  100076:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100079:	c9                   	leave  
  10007a:	c3                   	ret    

0010007b <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  10007b:	55                   	push   %ebp
  10007c:	89 e5                	mov    %esp,%ebp
  10007e:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  100081:	e8 a2 ff ff ff       	call   100028 <cpu_cur>
  100086:	3d 00 50 10 00       	cmp    $0x105000,%eax
  10008b:	0f 94 c0             	sete   %al
  10008e:	0f b6 c0             	movzbl %al,%eax
}
  100091:	c9                   	leave  
  100092:	c3                   	ret    

00100093 <init>:
// Called first from entry.S on the bootstrap processor,
// and later from boot/bootother.S on all other processors.
// As a rule, "init" functions in PIOS are called once on EACH processor.
void
init(void)
{
  100093:	55                   	push   %ebp
  100094:	89 e5                	mov    %esp,%ebp
  100096:	83 ec 18             	sub    $0x18,%esp
	extern char start[], edata[], end[];

	// Before anything else, complete the ELF loading process.
	// Clear all uninitialized global data (BSS) in our program,
	// ensuring that all static/global variables start out zero.
	if (cpu_onboot())
  100099:	e8 dd ff ff ff       	call   10007b <cpu_onboot>
  10009e:	85 c0                	test   %eax,%eax
  1000a0:	74 28                	je     1000ca <init+0x37>
		memset(edata, 0, end - edata);
  1000a2:	ba 84 7f 10 00       	mov    $0x107f84,%edx
  1000a7:	b8 30 65 10 00       	mov    $0x106530,%eax
  1000ac:	89 d1                	mov    %edx,%ecx
  1000ae:	29 c1                	sub    %eax,%ecx
  1000b0:	89 c8                	mov    %ecx,%eax
  1000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1000b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bd:	00 
  1000be:	c7 04 24 30 65 10 00 	movl   $0x106530,(%esp)
  1000c5:	e8 92 24 00 00       	call   10255c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  1000ca:	e8 ee 01 00 00       	call   1002bd <cons_init>

	// Lab 1: test cprintf and debug_trace
	cprintf("1234 decimal is %o octal!\n", 1234);
  1000cf:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
  1000d6:	00 
  1000d7:	c7 04 24 18 2a 10 00 	movl   $0x102a18,(%esp)
  1000de:	e8 92 22 00 00       	call   102375 <cprintf>
	debug_check();
  1000e3:	e8 ff 03 00 00       	call   1004e7 <debug_check>

	// Initialize and load the bootstrap CPU's GDT, TSS, and IDT.
	cpu_init();
  1000e8:	e8 62 0d 00 00       	call   100e4f <cpu_init>
	trap_init();
  1000ed:	e8 3f 0e 00 00       	call   100f31 <trap_init>

	// Physical memory detection/initialization.
	// Can't call mem_alloc until after we do this!
	mem_init();
  1000f2:	e8 a8 06 00 00       	call   10079f <mem_init>


	// Lab 1: change this so it enters user() in user mode,
	// running on the user_stack declared above,
	// instead of just calling user() directly.
	user();
  1000f7:	e8 02 00 00 00       	call   1000fe <user>
}
  1000fc:	c9                   	leave  
  1000fd:	c3                   	ret    

001000fe <user>:
// This is the first function that gets run in user mode (ring 3).
// It acts as PIOS's "root process",
// of which all other processes are descendants.
void
user()
{
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 28             	sub    $0x28,%esp
	cprintf("in user()\n");
  100104:	c7 04 24 33 2a 10 00 	movl   $0x102a33,(%esp)
  10010b:	e8 65 22 00 00       	call   102375 <cprintf>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100110:	89 65 f0             	mov    %esp,-0x10(%ebp)
        return esp;
  100113:	8b 45 f0             	mov    -0x10(%ebp),%eax
	assert(read_esp() > (uint32_t) &user_stack[0]);
  100116:	89 c2                	mov    %eax,%edx
  100118:	b8 40 65 10 00       	mov    $0x106540,%eax
  10011d:	39 c2                	cmp    %eax,%edx
  10011f:	77 24                	ja     100145 <user+0x47>
  100121:	c7 44 24 0c 40 2a 10 	movl   $0x102a40,0xc(%esp)
  100128:	00 
  100129:	c7 44 24 08 f6 29 10 	movl   $0x1029f6,0x8(%esp)
  100130:	00 
  100131:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100138:	00 
  100139:	c7 04 24 67 2a 10 00 	movl   $0x102a67,(%esp)
  100140:	e8 eb 01 00 00       	call   100330 <debug_panic>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100145:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
	assert(read_esp() < (uint32_t) &user_stack[sizeof(user_stack)]);
  10014b:	89 c2                	mov    %eax,%edx
  10014d:	b8 40 75 10 00       	mov    $0x107540,%eax
  100152:	39 c2                	cmp    %eax,%edx
  100154:	72 24                	jb     10017a <user+0x7c>
  100156:	c7 44 24 0c 74 2a 10 	movl   $0x102a74,0xc(%esp)
  10015d:	00 
  10015e:	c7 44 24 08 f6 29 10 	movl   $0x1029f6,0x8(%esp)
  100165:	00 
  100166:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  10016d:	00 
  10016e:	c7 04 24 67 2a 10 00 	movl   $0x102a67,(%esp)
  100175:	e8 b6 01 00 00       	call   100330 <debug_panic>

	// Check that we're in user mode and can handle traps from there.
	trap_check_user();
  10017a:	e8 b8 10 00 00       	call   101237 <trap_check_user>

	done();
  10017f:	e8 00 00 00 00       	call   100184 <done>

00100184 <done>:
// it just puts the processor into an infinite loop.
// We make this a function so that we can set a breakpoints on it.
// Our grade scripts use this breakpoint to know when to stop QEMU.
void gcc_noreturn
done()
{
  100184:	55                   	push   %ebp
  100185:	89 e5                	mov    %esp,%ebp
	while (1)
		;	// just spin
  100187:	eb fe                	jmp    100187 <done+0x3>
  100189:	90                   	nop
  10018a:	90                   	nop
  10018b:	90                   	nop

0010018c <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  10018c:	55                   	push   %ebp
  10018d:	89 e5                	mov    %esp,%ebp
  10018f:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100192:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100198:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10019b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10019e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1001a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1001a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1001a9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  1001af:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1001b4:	74 24                	je     1001da <cpu_cur+0x4e>
  1001b6:	c7 44 24 0c ac 2a 10 	movl   $0x102aac,0xc(%esp)
  1001bd:	00 
  1001be:	c7 44 24 08 c2 2a 10 	movl   $0x102ac2,0x8(%esp)
  1001c5:	00 
  1001c6:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  1001cd:	00 
  1001ce:	c7 04 24 d7 2a 10 00 	movl   $0x102ad7,(%esp)
  1001d5:	e8 56 01 00 00       	call   100330 <debug_panic>
	return c;
  1001da:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1001dd:	c9                   	leave  
  1001de:	c3                   	ret    

001001df <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  1001df:	55                   	push   %ebp
  1001e0:	89 e5                	mov    %esp,%ebp
  1001e2:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  1001e5:	e8 a2 ff ff ff       	call   10018c <cpu_cur>
  1001ea:	3d 00 50 10 00       	cmp    $0x105000,%eax
  1001ef:	0f 94 c0             	sete   %al
  1001f2:	0f b6 c0             	movzbl %al,%eax
}
  1001f5:	c9                   	leave  
  1001f6:	c3                   	ret    

001001f7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
  1001f7:	55                   	push   %ebp
  1001f8:	89 e5                	mov    %esp,%ebp
  1001fa:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
  1001fd:	eb 35                	jmp    100234 <cons_intr+0x3d>
		if (c == 0)
  1001ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100203:	74 2e                	je     100233 <cons_intr+0x3c>
			continue;
		cons.buf[cons.wpos++] = c;
  100205:	a1 44 77 10 00       	mov    0x107744,%eax
  10020a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10020d:	88 90 40 75 10 00    	mov    %dl,0x107540(%eax)
  100213:	83 c0 01             	add    $0x1,%eax
  100216:	a3 44 77 10 00       	mov    %eax,0x107744
		if (cons.wpos == CONSBUFSIZE)
  10021b:	a1 44 77 10 00       	mov    0x107744,%eax
  100220:	3d 00 02 00 00       	cmp    $0x200,%eax
  100225:	75 0d                	jne    100234 <cons_intr+0x3d>
			cons.wpos = 0;
  100227:	c7 05 44 77 10 00 00 	movl   $0x0,0x107744
  10022e:	00 00 00 
  100231:	eb 01                	jmp    100234 <cons_intr+0x3d>
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
  100233:	90                   	nop
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  100234:	8b 45 08             	mov    0x8(%ebp),%eax
  100237:	ff d0                	call   *%eax
  100239:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10023c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  100240:	75 bd                	jne    1001ff <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
  100242:	c9                   	leave  
  100243:	c3                   	ret    

00100244 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  100244:	55                   	push   %ebp
  100245:	89 e5                	mov    %esp,%ebp
  100247:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  10024a:	e8 b9 17 00 00       	call   101a08 <serial_intr>
	kbd_intr();
  10024f:	e8 0e 17 00 00       	call   101962 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  100254:	8b 15 40 77 10 00    	mov    0x107740,%edx
  10025a:	a1 44 77 10 00       	mov    0x107744,%eax
  10025f:	39 c2                	cmp    %eax,%edx
  100261:	74 35                	je     100298 <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
  100263:	a1 40 77 10 00       	mov    0x107740,%eax
  100268:	0f b6 90 40 75 10 00 	movzbl 0x107540(%eax),%edx
  10026f:	0f b6 d2             	movzbl %dl,%edx
  100272:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100275:	83 c0 01             	add    $0x1,%eax
  100278:	a3 40 77 10 00       	mov    %eax,0x107740
		if (cons.rpos == CONSBUFSIZE)
  10027d:	a1 40 77 10 00       	mov    0x107740,%eax
  100282:	3d 00 02 00 00       	cmp    $0x200,%eax
  100287:	75 0a                	jne    100293 <cons_getc+0x4f>
			cons.rpos = 0;
  100289:	c7 05 40 77 10 00 00 	movl   $0x0,0x107740
  100290:	00 00 00 
		return c;
  100293:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100296:	eb 05                	jmp    10029d <cons_getc+0x59>
	}
	return 0;
  100298:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10029d:	c9                   	leave  
  10029e:	c3                   	ret    

0010029f <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
  10029f:	55                   	push   %ebp
  1002a0:	89 e5                	mov    %esp,%ebp
  1002a2:	83 ec 18             	sub    $0x18,%esp
	serial_putc(c);
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 75 17 00 00       	call   101a25 <serial_putc>
	video_putc(c);
  1002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b3:	89 04 24             	mov    %eax,(%esp)
  1002b6:	e8 05 13 00 00       	call   1015c0 <video_putc>
}
  1002bb:	c9                   	leave  
  1002bc:	c3                   	ret    

001002bd <cons_init>:

// initialize the console devices
void
cons_init(void)
{
  1002bd:	55                   	push   %ebp
  1002be:	89 e5                	mov    %esp,%ebp
  1002c0:	83 ec 18             	sub    $0x18,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  1002c3:	e8 17 ff ff ff       	call   1001df <cpu_onboot>
  1002c8:	85 c0                	test   %eax,%eax
  1002ca:	74 36                	je     100302 <cons_init+0x45>
		return;

	video_init();
  1002cc:	e8 23 12 00 00       	call   1014f4 <video_init>
	kbd_init();
  1002d1:	e8 a0 16 00 00       	call   101976 <kbd_init>
	serial_init();
  1002d6:	e8 af 17 00 00       	call   101a8a <serial_init>

	if (!serial_exists)
  1002db:	a1 80 7f 10 00       	mov    0x107f80,%eax
  1002e0:	85 c0                	test   %eax,%eax
  1002e2:	75 1f                	jne    100303 <cons_init+0x46>
		warn("Serial port does not exist!\n");
  1002e4:	c7 44 24 08 e4 2a 10 	movl   $0x102ae4,0x8(%esp)
  1002eb:	00 
  1002ec:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  1002f3:	00 
  1002f4:	c7 04 24 01 2b 10 00 	movl   $0x102b01,(%esp)
  1002fb:	e8 ef 00 00 00       	call   1003ef <debug_warn>
  100300:	eb 01                	jmp    100303 <cons_init+0x46>
// initialize the console devices
void
cons_init(void)
{
	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  100302:	90                   	nop
	kbd_init();
	serial_init();

	if (!serial_exists)
		warn("Serial port does not exist!\n");
}
  100303:	c9                   	leave  
  100304:	c3                   	ret    

00100305 <cputs>:


// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
  100305:	55                   	push   %ebp
  100306:	89 e5                	mov    %esp,%ebp
  100308:	83 ec 28             	sub    $0x28,%esp
	char ch;
	while (*str)
  10030b:	eb 15                	jmp    100322 <cputs+0x1d>
		cons_putc(*str++);
  10030d:	8b 45 08             	mov    0x8(%ebp),%eax
  100310:	0f b6 00             	movzbl (%eax),%eax
  100313:	0f be c0             	movsbl %al,%eax
  100316:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10031a:	89 04 24             	mov    %eax,(%esp)
  10031d:	e8 7d ff ff ff       	call   10029f <cons_putc>
// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
	char ch;
	while (*str)
  100322:	8b 45 08             	mov    0x8(%ebp),%eax
  100325:	0f b6 00             	movzbl (%eax),%eax
  100328:	84 c0                	test   %al,%al
  10032a:	75 e1                	jne    10030d <cputs+0x8>
		cons_putc(*str++);
}
  10032c:	c9                   	leave  
  10032d:	c3                   	ret    
  10032e:	90                   	nop
  10032f:	90                   	nop

00100330 <debug_panic>:

// Panic is called on unresolvable fatal errors.
// It prints "panic: mesg", and then enters the kernel monitor.
void
debug_panic(const char *file, int line, const char *fmt,...)
{
  100330:	55                   	push   %ebp
  100331:	89 e5                	mov    %esp,%ebp
  100333:	83 ec 58             	sub    $0x58,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  100336:	8c 4d f2             	mov    %cs,-0xe(%ebp)
        return cs;
  100339:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
	va_list ap;
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
  10033d:	0f b7 c0             	movzwl %ax,%eax
  100340:	83 e0 03             	and    $0x3,%eax
  100343:	85 c0                	test   %eax,%eax
  100345:	75 15                	jne    10035c <debug_panic+0x2c>
		if (panicstr)
  100347:	a1 48 77 10 00       	mov    0x107748,%eax
  10034c:	85 c0                	test   %eax,%eax
  10034e:	0f 85 95 00 00 00    	jne    1003e9 <debug_panic+0xb9>
			goto dead;
		panicstr = fmt;
  100354:	8b 45 10             	mov    0x10(%ebp),%eax
  100357:	a3 48 77 10 00       	mov    %eax,0x107748
	}

	// First print the requested message
	va_start(ap, fmt);
  10035c:	8d 45 10             	lea    0x10(%ebp),%eax
  10035f:	83 c0 04             	add    $0x4,%eax
  100362:	89 45 e8             	mov    %eax,-0x18(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
  100365:	8b 45 0c             	mov    0xc(%ebp),%eax
  100368:	89 44 24 08          	mov    %eax,0x8(%esp)
  10036c:	8b 45 08             	mov    0x8(%ebp),%eax
  10036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100373:	c7 04 24 0d 2b 10 00 	movl   $0x102b0d,(%esp)
  10037a:	e8 f6 1f 00 00       	call   102375 <cprintf>
	vcprintf(fmt, ap);
  10037f:	8b 45 10             	mov    0x10(%ebp),%eax
  100382:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100385:	89 54 24 04          	mov    %edx,0x4(%esp)
  100389:	89 04 24             	mov    %eax,(%esp)
  10038c:	e8 7b 1f 00 00       	call   10230c <vcprintf>
	cprintf("\n");
  100391:	c7 04 24 25 2b 10 00 	movl   $0x102b25,(%esp)
  100398:	e8 d8 1f 00 00       	call   102375 <cprintf>

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  10039d:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  1003a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
  1003a3:	8d 55 c0             	lea    -0x40(%ebp),%edx
  1003a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003aa:	89 04 24             	mov    %eax,(%esp)
  1003ad:	e8 86 00 00 00       	call   100438 <debug_trace>
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  1003b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1003b9:	eb 1b                	jmp    1003d6 <debug_panic+0xa6>
		cprintf("  from %08x\n", eips[i]);
  1003bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003be:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  1003c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003c6:	c7 04 24 27 2b 10 00 	movl   $0x102b27,(%esp)
  1003cd:	e8 a3 1f 00 00       	call   102375 <cprintf>
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  1003d2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1003d6:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
  1003da:	7f 0e                	jg     1003ea <debug_panic+0xba>
  1003dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003df:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  1003e3:	85 c0                	test   %eax,%eax
  1003e5:	75 d4                	jne    1003bb <debug_panic+0x8b>
  1003e7:	eb 01                	jmp    1003ea <debug_panic+0xba>
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
		if (panicstr)
			goto dead;
  1003e9:	90                   	nop
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
		cprintf("  from %08x\n", eips[i]);

dead:
	done();		// enter infinite loop (see kern/init.c)
  1003ea:	e8 95 fd ff ff       	call   100184 <done>

001003ef <debug_warn>:
}

/* like panic, but don't */
void
debug_warn(const char *file, int line, const char *fmt,...)
{
  1003ef:	55                   	push   %ebp
  1003f0:	89 e5                	mov    %esp,%ebp
  1003f2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  1003f5:	8d 45 10             	lea    0x10(%ebp),%eax
  1003f8:	83 c0 04             	add    $0x4,%eax
  1003fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
  1003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100401:	89 44 24 08          	mov    %eax,0x8(%esp)
  100405:	8b 45 08             	mov    0x8(%ebp),%eax
  100408:	89 44 24 04          	mov    %eax,0x4(%esp)
  10040c:	c7 04 24 34 2b 10 00 	movl   $0x102b34,(%esp)
  100413:	e8 5d 1f 00 00       	call   102375 <cprintf>
	vcprintf(fmt, ap);
  100418:	8b 45 10             	mov    0x10(%ebp),%eax
  10041b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10041e:	89 54 24 04          	mov    %edx,0x4(%esp)
  100422:	89 04 24             	mov    %eax,(%esp)
  100425:	e8 e2 1e 00 00       	call   10230c <vcprintf>
	cprintf("\n");
  10042a:	c7 04 24 25 2b 10 00 	movl   $0x102b25,(%esp)
  100431:	e8 3f 1f 00 00       	call   102375 <cprintf>
	va_end(ap);
}
  100436:	c9                   	leave  
  100437:	c3                   	ret    

00100438 <debug_trace>:

// Record the current call stack in eips[] by following the %ebp chain.
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
  100438:	55                   	push   %ebp
  100439:	89 e5                	mov    %esp,%ebp
  10043b:	83 ec 18             	sub    $0x18,%esp
	panic("debug_trace not implemented");
  10043e:	c7 44 24 08 4e 2b 10 	movl   $0x102b4e,0x8(%esp)
  100445:	00 
  100446:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  10044d:	00 
  10044e:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  100455:	e8 d6 fe ff ff       	call   100330 <debug_panic>

0010045a <f3>:
}


static void gcc_noinline f3(int r, uint32_t *e) { debug_trace(read_ebp(), e); }
  10045a:	55                   	push   %ebp
  10045b:	89 e5                	mov    %esp,%ebp
  10045d:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  100460:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  100463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100466:	8b 55 0c             	mov    0xc(%ebp),%edx
  100469:	89 54 24 04          	mov    %edx,0x4(%esp)
  10046d:	89 04 24             	mov    %eax,(%esp)
  100470:	e8 c3 ff ff ff       	call   100438 <debug_trace>
  100475:	c9                   	leave  
  100476:	c3                   	ret    

00100477 <f2>:
static void gcc_noinline f2(int r, uint32_t *e) { r & 2 ? f3(r,e) : f3(r,e); }
  100477:	55                   	push   %ebp
  100478:	89 e5                	mov    %esp,%ebp
  10047a:	83 ec 18             	sub    $0x18,%esp
  10047d:	8b 45 08             	mov    0x8(%ebp),%eax
  100480:	83 e0 02             	and    $0x2,%eax
  100483:	85 c0                	test   %eax,%eax
  100485:	74 14                	je     10049b <f2+0x24>
  100487:	8b 45 0c             	mov    0xc(%ebp),%eax
  10048a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10048e:	8b 45 08             	mov    0x8(%ebp),%eax
  100491:	89 04 24             	mov    %eax,(%esp)
  100494:	e8 c1 ff ff ff       	call   10045a <f3>
  100499:	eb 12                	jmp    1004ad <f2+0x36>
  10049b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1004a5:	89 04 24             	mov    %eax,(%esp)
  1004a8:	e8 ad ff ff ff       	call   10045a <f3>
  1004ad:	c9                   	leave  
  1004ae:	c3                   	ret    

001004af <f1>:
static void gcc_noinline f1(int r, uint32_t *e) { r & 1 ? f2(r,e) : f2(r,e); }
  1004af:	55                   	push   %ebp
  1004b0:	89 e5                	mov    %esp,%ebp
  1004b2:	83 ec 18             	sub    $0x18,%esp
  1004b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1004b8:	83 e0 01             	and    $0x1,%eax
  1004bb:	84 c0                	test   %al,%al
  1004bd:	74 14                	je     1004d3 <f1+0x24>
  1004bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1004c9:	89 04 24             	mov    %eax,(%esp)
  1004cc:	e8 a6 ff ff ff       	call   100477 <f2>
  1004d1:	eb 12                	jmp    1004e5 <f1+0x36>
  1004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004da:	8b 45 08             	mov    0x8(%ebp),%eax
  1004dd:	89 04 24             	mov    %eax,(%esp)
  1004e0:	e8 92 ff ff ff       	call   100477 <f2>
  1004e5:	c9                   	leave  
  1004e6:	c3                   	ret    

001004e7 <debug_check>:

// Test the backtrace implementation for correct operation
void
debug_check(void)
{
  1004e7:	55                   	push   %ebp
  1004e8:	89 e5                	mov    %esp,%ebp
  1004ea:	81 ec c8 00 00 00    	sub    $0xc8,%esp
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  1004f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1004f7:	eb 29                	jmp    100522 <debug_check+0x3b>
		f1(i, eips[i]);
  1004f9:	8d 8d 50 ff ff ff    	lea    -0xb0(%ebp),%ecx
  1004ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100502:	89 d0                	mov    %edx,%eax
  100504:	c1 e0 02             	shl    $0x2,%eax
  100507:	01 d0                	add    %edx,%eax
  100509:	c1 e0 03             	shl    $0x3,%eax
  10050c:	8d 04 01             	lea    (%ecx,%eax,1),%eax
  10050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100513:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100516:	89 04 24             	mov    %eax,(%esp)
  100519:	e8 91 ff ff ff       	call   1004af <f1>
{
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  10051e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100522:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  100526:	7e d1                	jle    1004f9 <debug_check+0x12>
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  100528:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10052f:	e9 bc 00 00 00       	jmp    1005f0 <debug_check+0x109>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  100534:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10053b:	e9 a2 00 00 00       	jmp    1005e2 <debug_check+0xfb>
			assert((eips[r][i] != 0) == (i < 5));
  100540:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100543:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100546:	89 d0                	mov    %edx,%eax
  100548:	c1 e0 02             	shl    $0x2,%eax
  10054b:	01 d0                	add    %edx,%eax
  10054d:	01 c0                	add    %eax,%eax
  10054f:	01 c8                	add    %ecx,%eax
  100551:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  100558:	85 c0                	test   %eax,%eax
  10055a:	0f 95 c2             	setne  %dl
  10055d:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
  100561:	0f 9e c0             	setle  %al
  100564:	31 d0                	xor    %edx,%eax
  100566:	84 c0                	test   %al,%al
  100568:	74 24                	je     10058e <debug_check+0xa7>
  10056a:	c7 44 24 0c 77 2b 10 	movl   $0x102b77,0xc(%esp)
  100571:	00 
  100572:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  100579:	00 
  10057a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  100581:	00 
  100582:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  100589:	e8 a2 fd ff ff       	call   100330 <debug_panic>
			if (i >= 2)
  10058e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  100592:	7e 4a                	jle    1005de <debug_check+0xf7>
				assert(eips[r][i] == eips[0][i]);
  100594:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100597:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  10059a:	89 d0                	mov    %edx,%eax
  10059c:	c1 e0 02             	shl    $0x2,%eax
  10059f:	01 d0                	add    %edx,%eax
  1005a1:	01 c0                	add    %eax,%eax
  1005a3:	01 c8                	add    %ecx,%eax
  1005a5:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
  1005ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005af:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  1005b6:	39 c2                	cmp    %eax,%edx
  1005b8:	74 24                	je     1005de <debug_check+0xf7>
  1005ba:	c7 44 24 0c a9 2b 10 	movl   $0x102ba9,0xc(%esp)
  1005c1:	00 
  1005c2:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  1005c9:	00 
  1005ca:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  1005d1:	00 
  1005d2:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  1005d9:	e8 52 fd ff ff       	call   100330 <debug_panic>
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  1005de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1005e2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  1005e6:	0f 8e 54 ff ff ff    	jle    100540 <debug_check+0x59>
	// produce several related backtraces...
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  1005ec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  1005f0:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  1005f4:	0f 8e 3a ff ff ff    	jle    100534 <debug_check+0x4d>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
			assert((eips[r][i] != 0) == (i < 5));
			if (i >= 2)
				assert(eips[r][i] == eips[0][i]);
		}
	assert(eips[0][0] == eips[1][0]);
  1005fa:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  100600:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  100606:	39 c2                	cmp    %eax,%edx
  100608:	74 24                	je     10062e <debug_check+0x147>
  10060a:	c7 44 24 0c c2 2b 10 	movl   $0x102bc2,0xc(%esp)
  100611:	00 
  100612:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  100619:	00 
  10061a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  100621:	00 
  100622:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  100629:	e8 02 fd ff ff       	call   100330 <debug_panic>
	assert(eips[2][0] == eips[3][0]);
  10062e:	8b 55 a0             	mov    -0x60(%ebp),%edx
  100631:	8b 45 c8             	mov    -0x38(%ebp),%eax
  100634:	39 c2                	cmp    %eax,%edx
  100636:	74 24                	je     10065c <debug_check+0x175>
  100638:	c7 44 24 0c db 2b 10 	movl   $0x102bdb,0xc(%esp)
  10063f:	00 
  100640:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  100647:	00 
  100648:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  10064f:	00 
  100650:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  100657:	e8 d4 fc ff ff       	call   100330 <debug_panic>
	assert(eips[1][0] != eips[2][0]);
  10065c:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
  100662:	8b 45 a0             	mov    -0x60(%ebp),%eax
  100665:	39 c2                	cmp    %eax,%edx
  100667:	75 24                	jne    10068d <debug_check+0x1a6>
  100669:	c7 44 24 0c f4 2b 10 	movl   $0x102bf4,0xc(%esp)
  100670:	00 
  100671:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  100678:	00 
  100679:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  100680:	00 
  100681:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  100688:	e8 a3 fc ff ff       	call   100330 <debug_panic>
	assert(eips[0][1] == eips[2][1]);
  10068d:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  100693:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  100696:	39 c2                	cmp    %eax,%edx
  100698:	74 24                	je     1006be <debug_check+0x1d7>
  10069a:	c7 44 24 0c 0d 2c 10 	movl   $0x102c0d,0xc(%esp)
  1006a1:	00 
  1006a2:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  1006a9:	00 
  1006aa:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  1006b1:	00 
  1006b2:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  1006b9:	e8 72 fc ff ff       	call   100330 <debug_panic>
	assert(eips[1][1] == eips[3][1]);
  1006be:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  1006c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1006c7:	39 c2                	cmp    %eax,%edx
  1006c9:	74 24                	je     1006ef <debug_check+0x208>
  1006cb:	c7 44 24 0c 26 2c 10 	movl   $0x102c26,0xc(%esp)
  1006d2:	00 
  1006d3:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  1006da:	00 
  1006db:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  1006e2:	00 
  1006e3:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  1006ea:	e8 41 fc ff ff       	call   100330 <debug_panic>
	assert(eips[0][1] != eips[1][1]);
  1006ef:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  1006f5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  1006fb:	39 c2                	cmp    %eax,%edx
  1006fd:	75 24                	jne    100723 <debug_check+0x23c>
  1006ff:	c7 44 24 0c 3f 2c 10 	movl   $0x102c3f,0xc(%esp)
  100706:	00 
  100707:	c7 44 24 08 94 2b 10 	movl   $0x102b94,0x8(%esp)
  10070e:	00 
  10070f:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  100716:	00 
  100717:	c7 04 24 6a 2b 10 00 	movl   $0x102b6a,(%esp)
  10071e:	e8 0d fc ff ff       	call   100330 <debug_panic>

	cprintf("debug_check() succeeded!\n");
  100723:	c7 04 24 58 2c 10 00 	movl   $0x102c58,(%esp)
  10072a:	e8 46 1c 00 00       	call   102375 <cprintf>
}
  10072f:	c9                   	leave  
  100730:	c3                   	ret    
  100731:	90                   	nop
  100732:	90                   	nop
  100733:	90                   	nop

00100734 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100734:	55                   	push   %ebp
  100735:	89 e5                	mov    %esp,%ebp
  100737:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10073a:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  10073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100740:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100746:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10074b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  10074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100751:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  100757:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  10075c:	74 24                	je     100782 <cpu_cur+0x4e>
  10075e:	c7 44 24 0c 74 2c 10 	movl   $0x102c74,0xc(%esp)
  100765:	00 
  100766:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  10076d:	00 
  10076e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100775:	00 
  100776:	c7 04 24 9f 2c 10 00 	movl   $0x102c9f,(%esp)
  10077d:	e8 ae fb ff ff       	call   100330 <debug_panic>
	return c;
  100782:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100785:	c9                   	leave  
  100786:	c3                   	ret    

00100787 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  100787:	55                   	push   %ebp
  100788:	89 e5                	mov    %esp,%ebp
  10078a:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  10078d:	e8 a2 ff ff ff       	call   100734 <cpu_cur>
  100792:	3d 00 50 10 00       	cmp    $0x105000,%eax
  100797:	0f 94 c0             	sete   %al
  10079a:	0f b6 c0             	movzbl %al,%eax
}
  10079d:	c9                   	leave  
  10079e:	c3                   	ret    

0010079f <mem_init>:

void mem_check(void);

void
mem_init(void)
{
  10079f:	55                   	push   %ebp
  1007a0:	89 e5                	mov    %esp,%ebp
  1007a2:	83 ec 38             	sub    $0x38,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  1007a5:	e8 dd ff ff ff       	call   100787 <cpu_onboot>
  1007aa:	85 c0                	test   %eax,%eax
  1007ac:	0f 84 2d 01 00 00    	je     1008df <mem_init+0x140>
	// is available in the system (in bytes),
	// by reading the PC's BIOS-managed nonvolatile RAM (NVRAM).
	// The NVRAM tells us how many kilobytes there are.
	// Since the count is 16 bits, this gives us up to 64MB of RAM;
	// additional RAM beyond that would have to be detected another way.
	size_t basemem = ROUNDDOWN(nvram_read16(NVRAM_BASELO)*1024, PAGESIZE);
  1007b2:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
  1007b9:	e8 d1 13 00 00       	call   101b8f <nvram_read16>
  1007be:	c1 e0 0a             	shl    $0xa,%eax
  1007c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1007c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1007c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1007cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t extmem = ROUNDDOWN(nvram_read16(NVRAM_EXTLO)*1024, PAGESIZE);
  1007cf:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
  1007d6:	e8 b4 13 00 00       	call   101b8f <nvram_read16>
  1007db:	c1 e0 0a             	shl    $0xa,%eax
  1007de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1007e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	warn("Assuming we have 1GB of memory!");
  1007ec:	c7 44 24 08 ac 2c 10 	movl   $0x102cac,0x8(%esp)
  1007f3:	00 
  1007f4:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  1007fb:	00 
  1007fc:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100803:	e8 e7 fb ff ff       	call   1003ef <debug_warn>
	extmem = 1024*1024*1024 - MEM_EXT;	// assume 1GB total memory
  100808:	c7 45 e4 00 00 f0 3f 	movl   $0x3ff00000,-0x1c(%ebp)

	// The maximum physical address is the top of extended memory.
	mem_max = MEM_EXT + extmem;
  10080f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100812:	05 00 00 10 00       	add    $0x100000,%eax
  100817:	a3 78 7f 10 00       	mov    %eax,0x107f78

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;
  10081c:	a1 78 7f 10 00       	mov    0x107f78,%eax
  100821:	c1 e8 0c             	shr    $0xc,%eax
  100824:	a3 74 7f 10 00       	mov    %eax,0x107f74

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
  100829:	a1 78 7f 10 00       	mov    0x107f78,%eax
  10082e:	c1 e8 0a             	shr    $0xa,%eax
  100831:	89 44 24 04          	mov    %eax,0x4(%esp)
  100835:	c7 04 24 d8 2c 10 00 	movl   $0x102cd8,(%esp)
  10083c:	e8 34 1b 00 00       	call   102375 <cprintf>
	cprintf("base = %dK, extended = %dK\n",
		(int)(basemem/1024), (int)(extmem/1024));
  100841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100844:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  100847:	89 c2                	mov    %eax,%edx
		(int)(basemem/1024), (int)(extmem/1024));
  100849:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10084c:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  10084f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100853:	89 44 24 04          	mov    %eax,0x4(%esp)
  100857:	c7 04 24 f9 2c 10 00 	movl   $0x102cf9,(%esp)
  10085e:	e8 12 1b 00 00       	call   102375 <cprintf>
	//     Some of it is in use, some is free.
	//     Which pages hold the kernel and the pageinfo array?
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
  100863:	c7 45 e8 70 7f 10 00 	movl   $0x107f70,-0x18(%ebp)
	int i;
	for (i = 0; i < mem_npage; i++) {
  10086a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100871:	eb 3b                	jmp    1008ae <mem_init+0x10f>
		// A free page has no references to it.
		mem_pageinfo[i].refcount = 0;
  100873:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100878:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10087b:	c1 e2 03             	shl    $0x3,%edx
  10087e:	01 d0                	add    %edx,%eax
  100880:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
  100887:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  10088c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10088f:	c1 e2 03             	shl    $0x3,%edx
  100892:	8d 14 10             	lea    (%eax,%edx,1),%edx
  100895:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100898:	89 10                	mov    %edx,(%eax)
		freetail = &mem_pageinfo[i].free_next;
  10089a:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  10089f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008a2:	c1 e2 03             	shl    $0x3,%edx
  1008a5:	01 d0                	add    %edx,%eax
  1008a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
	int i;
	for (i = 0; i < mem_npage; i++) {
  1008aa:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1008ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008b1:	a1 74 7f 10 00       	mov    0x107f74,%eax
  1008b6:	39 c2                	cmp    %eax,%edx
  1008b8:	72 b9                	jb     100873 <mem_init+0xd4>

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
		freetail = &mem_pageinfo[i].free_next;
	}
	*freetail = NULL;	// null-terminate the freelist
  1008ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1008bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// ...and remove this when you're ready.
	panic("mem_init() not implemented");
  1008c3:	c7 44 24 08 15 2d 10 	movl   $0x102d15,0x8(%esp)
  1008ca:	00 
  1008cb:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  1008d2:	00 
  1008d3:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  1008da:	e8 51 fa ff ff       	call   100330 <debug_panic>

	// Check to make sure the page allocator seems to work correctly.
	mem_check();
}
  1008df:	c9                   	leave  
  1008e0:	c3                   	ret    

001008e1 <mem_alloc>:
//
// Hint: pi->refs should not be incremented 
// Hint: be sure to use proper mutual exclusion for multiprocessor operation.
pageinfo *
mem_alloc(void)
{
  1008e1:	55                   	push   %ebp
  1008e2:	89 e5                	mov    %esp,%ebp
  1008e4:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	// Fill this function in.
	panic("mem_alloc not implemented.");
  1008e7:	c7 44 24 08 30 2d 10 	movl   $0x102d30,0x8(%esp)
  1008ee:	00 
  1008ef:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  1008f6:	00 
  1008f7:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  1008fe:	e8 2d fa ff ff       	call   100330 <debug_panic>

00100903 <mem_free>:
// Return a page to the free list, given its pageinfo pointer.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
mem_free(pageinfo *pi)
{
  100903:	55                   	push   %ebp
  100904:	89 e5                	mov    %esp,%ebp
  100906:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in.
	panic("mem_free not implemented.");
  100909:	c7 44 24 08 4b 2d 10 	movl   $0x102d4b,0x8(%esp)
  100910:	00 
  100911:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  100918:	00 
  100919:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100920:	e8 0b fa ff ff       	call   100330 <debug_panic>

00100925 <mem_check>:
// Check the physical page allocator (mem_alloc(), mem_free())
// for correct operation after initialization via mem_init().
//
void
mem_check()
{
  100925:	55                   	push   %ebp
  100926:	89 e5                	mov    %esp,%ebp
  100928:	83 ec 38             	sub    $0x38,%esp
	int i;

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
  10092b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  100932:	a1 70 7f 10 00       	mov    0x107f70,%eax
  100937:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10093a:	eb 38                	jmp    100974 <mem_check+0x4f>
		memset(mem_pi2ptr(pp), 0x97, 128);
  10093c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10093f:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100944:	89 d1                	mov    %edx,%ecx
  100946:	29 c1                	sub    %eax,%ecx
  100948:	89 c8                	mov    %ecx,%eax
  10094a:	c1 f8 03             	sar    $0x3,%eax
  10094d:	c1 e0 0c             	shl    $0xc,%eax
  100950:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  100957:	00 
  100958:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  10095f:	00 
  100960:	89 04 24             	mov    %eax,(%esp)
  100963:	e8 f4 1b 00 00       	call   10255c <memset>
		freepages++;
  100968:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  10096c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10096f:	8b 00                	mov    (%eax),%eax
  100971:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100974:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  100978:	75 c2                	jne    10093c <mem_check+0x17>
		memset(mem_pi2ptr(pp), 0x97, 128);
		freepages++;
	}
	cprintf("mem_check: %d free pages\n", freepages);
  10097a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100981:	c7 04 24 65 2d 10 00 	movl   $0x102d65,(%esp)
  100988:	e8 e8 19 00 00       	call   102375 <cprintf>
	assert(freepages < mem_npage);	// can't have more free than total!
  10098d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100990:	a1 74 7f 10 00       	mov    0x107f74,%eax
  100995:	39 c2                	cmp    %eax,%edx
  100997:	72 24                	jb     1009bd <mem_check+0x98>
  100999:	c7 44 24 0c 7f 2d 10 	movl   $0x102d7f,0xc(%esp)
  1009a0:	00 
  1009a1:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  1009a8:	00 
  1009a9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  1009b0:	00 
  1009b1:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  1009b8:	e8 73 f9 ff ff       	call   100330 <debug_panic>
	assert(freepages > 16000);	// make sure it's in the right ballpark
  1009bd:	81 7d f4 80 3e 00 00 	cmpl   $0x3e80,-0xc(%ebp)
  1009c4:	7f 24                	jg     1009ea <mem_check+0xc5>
  1009c6:	c7 44 24 0c 95 2d 10 	movl   $0x102d95,0xc(%esp)
  1009cd:	00 
  1009ce:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  1009d5:	00 
  1009d6:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  1009dd:	00 
  1009de:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  1009e5:	e8 46 f9 ff ff       	call   100330 <debug_panic>

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
  1009ea:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  1009f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1009f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1009fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  1009fd:	e8 df fe ff ff       	call   1008e1 <mem_alloc>
  100a02:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100a05:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100a09:	75 24                	jne    100a2f <mem_check+0x10a>
  100a0b:	c7 44 24 0c a7 2d 10 	movl   $0x102da7,0xc(%esp)
  100a12:	00 
  100a13:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100a1a:	00 
  100a1b:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  100a22:	00 
  100a23:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100a2a:	e8 01 f9 ff ff       	call   100330 <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100a2f:	e8 ad fe ff ff       	call   1008e1 <mem_alloc>
  100a34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100a37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100a3b:	75 24                	jne    100a61 <mem_check+0x13c>
  100a3d:	c7 44 24 0c b0 2d 10 	movl   $0x102db0,0xc(%esp)
  100a44:	00 
  100a45:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100a4c:	00 
  100a4d:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  100a54:	00 
  100a55:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100a5c:	e8 cf f8 ff ff       	call   100330 <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100a61:	e8 7b fe ff ff       	call   1008e1 <mem_alloc>
  100a66:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100a69:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100a6d:	75 24                	jne    100a93 <mem_check+0x16e>
  100a6f:	c7 44 24 0c b9 2d 10 	movl   $0x102db9,0xc(%esp)
  100a76:	00 
  100a77:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100a7e:	00 
  100a7f:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  100a86:	00 
  100a87:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100a8e:	e8 9d f8 ff ff       	call   100330 <debug_panic>

	assert(pp0);
  100a93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100a97:	75 24                	jne    100abd <mem_check+0x198>
  100a99:	c7 44 24 0c c2 2d 10 	movl   $0x102dc2,0xc(%esp)
  100aa0:	00 
  100aa1:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100aa8:	00 
  100aa9:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  100ab0:	00 
  100ab1:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100ab8:	e8 73 f8 ff ff       	call   100330 <debug_panic>
	assert(pp1 && pp1 != pp0);
  100abd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100ac1:	74 08                	je     100acb <mem_check+0x1a6>
  100ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ac6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100ac9:	75 24                	jne    100aef <mem_check+0x1ca>
  100acb:	c7 44 24 0c c6 2d 10 	movl   $0x102dc6,0xc(%esp)
  100ad2:	00 
  100ad3:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100ada:	00 
  100adb:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  100ae2:	00 
  100ae3:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100aea:	e8 41 f8 ff ff       	call   100330 <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  100aef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100af3:	74 10                	je     100b05 <mem_check+0x1e0>
  100af5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100af8:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  100afb:	74 08                	je     100b05 <mem_check+0x1e0>
  100afd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b00:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100b03:	75 24                	jne    100b29 <mem_check+0x204>
  100b05:	c7 44 24 0c d8 2d 10 	movl   $0x102dd8,0xc(%esp)
  100b0c:	00 
  100b0d:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100b14:	00 
  100b15:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  100b1c:	00 
  100b1d:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100b24:	e8 07 f8 ff ff       	call   100330 <debug_panic>
        assert(mem_pi2phys(pp0) < mem_npage*PAGESIZE);
  100b29:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100b2c:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100b31:	89 d1                	mov    %edx,%ecx
  100b33:	29 c1                	sub    %eax,%ecx
  100b35:	89 c8                	mov    %ecx,%eax
  100b37:	c1 f8 03             	sar    $0x3,%eax
  100b3a:	c1 e0 0c             	shl    $0xc,%eax
  100b3d:	8b 15 74 7f 10 00    	mov    0x107f74,%edx
  100b43:	c1 e2 0c             	shl    $0xc,%edx
  100b46:	39 d0                	cmp    %edx,%eax
  100b48:	72 24                	jb     100b6e <mem_check+0x249>
  100b4a:	c7 44 24 0c f8 2d 10 	movl   $0x102df8,0xc(%esp)
  100b51:	00 
  100b52:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100b59:	00 
  100b5a:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  100b61:	00 
  100b62:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100b69:	e8 c2 f7 ff ff       	call   100330 <debug_panic>
        assert(mem_pi2phys(pp1) < mem_npage*PAGESIZE);
  100b6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100b71:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100b76:	89 d1                	mov    %edx,%ecx
  100b78:	29 c1                	sub    %eax,%ecx
  100b7a:	89 c8                	mov    %ecx,%eax
  100b7c:	c1 f8 03             	sar    $0x3,%eax
  100b7f:	c1 e0 0c             	shl    $0xc,%eax
  100b82:	8b 15 74 7f 10 00    	mov    0x107f74,%edx
  100b88:	c1 e2 0c             	shl    $0xc,%edx
  100b8b:	39 d0                	cmp    %edx,%eax
  100b8d:	72 24                	jb     100bb3 <mem_check+0x28e>
  100b8f:	c7 44 24 0c 20 2e 10 	movl   $0x102e20,0xc(%esp)
  100b96:	00 
  100b97:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100b9e:	00 
  100b9f:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  100ba6:	00 
  100ba7:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100bae:	e8 7d f7 ff ff       	call   100330 <debug_panic>
        assert(mem_pi2phys(pp2) < mem_npage*PAGESIZE);
  100bb3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100bb6:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100bbb:	89 d1                	mov    %edx,%ecx
  100bbd:	29 c1                	sub    %eax,%ecx
  100bbf:	89 c8                	mov    %ecx,%eax
  100bc1:	c1 f8 03             	sar    $0x3,%eax
  100bc4:	c1 e0 0c             	shl    $0xc,%eax
  100bc7:	8b 15 74 7f 10 00    	mov    0x107f74,%edx
  100bcd:	c1 e2 0c             	shl    $0xc,%edx
  100bd0:	39 d0                	cmp    %edx,%eax
  100bd2:	72 24                	jb     100bf8 <mem_check+0x2d3>
  100bd4:	c7 44 24 0c 48 2e 10 	movl   $0x102e48,0xc(%esp)
  100bdb:	00 
  100bdc:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100be3:	00 
  100be4:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  100beb:	00 
  100bec:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100bf3:	e8 38 f7 ff ff       	call   100330 <debug_panic>

	// temporarily steal the rest of the free pages
	fl = mem_freelist;
  100bf8:	a1 70 7f 10 00       	mov    0x107f70,%eax
  100bfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mem_freelist = 0;
  100c00:	c7 05 70 7f 10 00 00 	movl   $0x0,0x107f70
  100c07:	00 00 00 

	// should be no free memory
	assert(mem_alloc() == 0);
  100c0a:	e8 d2 fc ff ff       	call   1008e1 <mem_alloc>
  100c0f:	85 c0                	test   %eax,%eax
  100c11:	74 24                	je     100c37 <mem_check+0x312>
  100c13:	c7 44 24 0c 6e 2e 10 	movl   $0x102e6e,0xc(%esp)
  100c1a:	00 
  100c1b:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100c22:	00 
  100c23:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  100c2a:	00 
  100c2b:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100c32:	e8 f9 f6 ff ff       	call   100330 <debug_panic>

        // free and re-allocate?
        mem_free(pp0);
  100c37:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100c3a:	89 04 24             	mov    %eax,(%esp)
  100c3d:	e8 c1 fc ff ff       	call   100903 <mem_free>
        mem_free(pp1);
  100c42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100c45:	89 04 24             	mov    %eax,(%esp)
  100c48:	e8 b6 fc ff ff       	call   100903 <mem_free>
        mem_free(pp2);
  100c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100c50:	89 04 24             	mov    %eax,(%esp)
  100c53:	e8 ab fc ff ff       	call   100903 <mem_free>
	pp0 = pp1 = pp2 = 0;
  100c58:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100c5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100c62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100c65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100c68:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  100c6b:	e8 71 fc ff ff       	call   1008e1 <mem_alloc>
  100c70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100c73:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100c77:	75 24                	jne    100c9d <mem_check+0x378>
  100c79:	c7 44 24 0c a7 2d 10 	movl   $0x102da7,0xc(%esp)
  100c80:	00 
  100c81:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100c88:	00 
  100c89:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
  100c90:	00 
  100c91:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100c98:	e8 93 f6 ff ff       	call   100330 <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100c9d:	e8 3f fc ff ff       	call   1008e1 <mem_alloc>
  100ca2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100ca5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100ca9:	75 24                	jne    100ccf <mem_check+0x3aa>
  100cab:	c7 44 24 0c b0 2d 10 	movl   $0x102db0,0xc(%esp)
  100cb2:	00 
  100cb3:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100cba:	00 
  100cbb:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
  100cc2:	00 
  100cc3:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100cca:	e8 61 f6 ff ff       	call   100330 <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100ccf:	e8 0d fc ff ff       	call   1008e1 <mem_alloc>
  100cd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100cd7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100cdb:	75 24                	jne    100d01 <mem_check+0x3dc>
  100cdd:	c7 44 24 0c b9 2d 10 	movl   $0x102db9,0xc(%esp)
  100ce4:	00 
  100ce5:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100cec:	00 
  100ced:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  100cf4:	00 
  100cf5:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100cfc:	e8 2f f6 ff ff       	call   100330 <debug_panic>
	assert(pp0);
  100d01:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100d05:	75 24                	jne    100d2b <mem_check+0x406>
  100d07:	c7 44 24 0c c2 2d 10 	movl   $0x102dc2,0xc(%esp)
  100d0e:	00 
  100d0f:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100d16:	00 
  100d17:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  100d1e:	00 
  100d1f:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100d26:	e8 05 f6 ff ff       	call   100330 <debug_panic>
	assert(pp1 && pp1 != pp0);
  100d2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100d2f:	74 08                	je     100d39 <mem_check+0x414>
  100d31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100d34:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100d37:	75 24                	jne    100d5d <mem_check+0x438>
  100d39:	c7 44 24 0c c6 2d 10 	movl   $0x102dc6,0xc(%esp)
  100d40:	00 
  100d41:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100d48:	00 
  100d49:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  100d50:	00 
  100d51:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100d58:	e8 d3 f5 ff ff       	call   100330 <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  100d5d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100d61:	74 10                	je     100d73 <mem_check+0x44e>
  100d63:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100d66:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  100d69:	74 08                	je     100d73 <mem_check+0x44e>
  100d6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100d6e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100d71:	75 24                	jne    100d97 <mem_check+0x472>
  100d73:	c7 44 24 0c d8 2d 10 	movl   $0x102dd8,0xc(%esp)
  100d7a:	00 
  100d7b:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100d82:	00 
  100d83:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  100d8a:	00 
  100d8b:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100d92:	e8 99 f5 ff ff       	call   100330 <debug_panic>
	assert(mem_alloc() == 0);
  100d97:	e8 45 fb ff ff       	call   1008e1 <mem_alloc>
  100d9c:	85 c0                	test   %eax,%eax
  100d9e:	74 24                	je     100dc4 <mem_check+0x49f>
  100da0:	c7 44 24 0c 6e 2e 10 	movl   $0x102e6e,0xc(%esp)
  100da7:	00 
  100da8:	c7 44 24 08 8a 2c 10 	movl   $0x102c8a,0x8(%esp)
  100daf:	00 
  100db0:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
  100db7:	00 
  100db8:	c7 04 24 cc 2c 10 00 	movl   $0x102ccc,(%esp)
  100dbf:	e8 6c f5 ff ff       	call   100330 <debug_panic>

	// give free list back
	mem_freelist = fl;
  100dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100dc7:	a3 70 7f 10 00       	mov    %eax,0x107f70

	// free the pages we took
	mem_free(pp0);
  100dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100dcf:	89 04 24             	mov    %eax,(%esp)
  100dd2:	e8 2c fb ff ff       	call   100903 <mem_free>
	mem_free(pp1);
  100dd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100dda:	89 04 24             	mov    %eax,(%esp)
  100ddd:	e8 21 fb ff ff       	call   100903 <mem_free>
	mem_free(pp2);
  100de2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100de5:	89 04 24             	mov    %eax,(%esp)
  100de8:	e8 16 fb ff ff       	call   100903 <mem_free>

	cprintf("mem_check() succeeded!\n");
  100ded:	c7 04 24 7f 2e 10 00 	movl   $0x102e7f,(%esp)
  100df4:	e8 7c 15 00 00       	call   102375 <cprintf>
}
  100df9:	c9                   	leave  
  100dfa:	c3                   	ret    
  100dfb:	90                   	nop

00100dfc <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100dfc:	55                   	push   %ebp
  100dfd:	89 e5                	mov    %esp,%ebp
  100dff:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100e02:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100e08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100e0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100e13:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100e16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100e19:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  100e1f:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100e24:	74 24                	je     100e4a <cpu_cur+0x4e>
  100e26:	c7 44 24 0c 97 2e 10 	movl   $0x102e97,0xc(%esp)
  100e2d:	00 
  100e2e:	c7 44 24 08 ad 2e 10 	movl   $0x102ead,0x8(%esp)
  100e35:	00 
  100e36:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100e3d:	00 
  100e3e:	c7 04 24 c2 2e 10 00 	movl   $0x102ec2,(%esp)
  100e45:	e8 e6 f4 ff ff       	call   100330 <debug_panic>
	return c;
  100e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100e4d:	c9                   	leave  
  100e4e:	c3                   	ret    

00100e4f <cpu_init>:
	magic: CPU_MAGIC
};


void cpu_init()
{
  100e4f:	55                   	push   %ebp
  100e50:	89 e5                	mov    %esp,%ebp
  100e52:	83 ec 18             	sub    $0x18,%esp
	cpu *c = cpu_cur();
  100e55:	e8 a2 ff ff ff       	call   100dfc <cpu_cur>
  100e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Load the GDT
	struct pseudodesc gdt_pd = {
		sizeof(c->gdt) - 1, (uint32_t) c->gdt };
  100e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100e60:	66 c7 45 ee 37 00    	movw   $0x37,-0x12(%ebp)
  100e66:	89 45 f0             	mov    %eax,-0x10(%ebp)
	asm volatile("lgdt %0" : : "m" (gdt_pd));
  100e69:	0f 01 55 ee          	lgdtl  -0x12(%ebp)

	// Reload all segment registers.
	asm volatile("movw %%ax,%%gs" :: "a" (CPU_GDT_UDATA|3));
  100e6d:	b8 23 00 00 00       	mov    $0x23,%eax
  100e72:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (CPU_GDT_UDATA|3));
  100e74:	b8 23 00 00 00       	mov    $0x23,%eax
  100e79:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (CPU_GDT_KDATA));
  100e7b:	b8 10 00 00 00       	mov    $0x10,%eax
  100e80:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (CPU_GDT_KDATA));
  100e82:	b8 10 00 00 00       	mov    $0x10,%eax
  100e87:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (CPU_GDT_KDATA));
  100e89:	b8 10 00 00 00       	mov    $0x10,%eax
  100e8e:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (CPU_GDT_KCODE)); // reload CS
  100e90:	ea 97 0e 10 00 08 00 	ljmp   $0x8,$0x100e97

	// We don't need an LDT.
	asm volatile("lldt %%ax" :: "a" (0));
  100e97:	b8 00 00 00 00       	mov    $0x0,%eax
  100e9c:	0f 00 d0             	lldt   %ax
}
  100e9f:	c9                   	leave  
  100ea0:	c3                   	ret    
  100ea1:	90                   	nop
  100ea2:	90                   	nop
  100ea3:	90                   	nop

00100ea4 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100ea4:	55                   	push   %ebp
  100ea5:	89 e5                	mov    %esp,%ebp
  100ea7:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100eaa:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100eb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100ebb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100ec1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  100ec7:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100ecc:	74 24                	je     100ef2 <cpu_cur+0x4e>
  100ece:	c7 44 24 0c e0 2e 10 	movl   $0x102ee0,0xc(%esp)
  100ed5:	00 
  100ed6:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  100edd:	00 
  100ede:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100ee5:	00 
  100ee6:	c7 04 24 0b 2f 10 00 	movl   $0x102f0b,(%esp)
  100eed:	e8 3e f4 ff ff       	call   100330 <debug_panic>
	return c;
  100ef2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100ef5:	c9                   	leave  
  100ef6:	c3                   	ret    

00100ef7 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  100ef7:	55                   	push   %ebp
  100ef8:	89 e5                	mov    %esp,%ebp
  100efa:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  100efd:	e8 a2 ff ff ff       	call   100ea4 <cpu_cur>
  100f02:	3d 00 50 10 00       	cmp    $0x105000,%eax
  100f07:	0f 94 c0             	sete   %al
  100f0a:	0f b6 c0             	movzbl %al,%eax
}
  100f0d:	c9                   	leave  
  100f0e:	c3                   	ret    

00100f0f <trap_init_idt>:
};


static void
trap_init_idt(void)
{
  100f0f:	55                   	push   %ebp
  100f10:	89 e5                	mov    %esp,%ebp
  100f12:	83 ec 18             	sub    $0x18,%esp
	extern segdesc gdt[];
	
	panic("trap_init() not implemented.");
  100f15:	c7 44 24 08 18 2f 10 	movl   $0x102f18,0x8(%esp)
  100f1c:	00 
  100f1d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  100f24:	00 
  100f25:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  100f2c:	e8 ff f3 ff ff       	call   100330 <debug_panic>

00100f31 <trap_init>:
}

void
trap_init(void)
{
  100f31:	55                   	push   %ebp
  100f32:	89 e5                	mov    %esp,%ebp
  100f34:	83 ec 08             	sub    $0x8,%esp
	// The first time we get called on the bootstrap processor,
	// initialize the IDT.  Other CPUs will share the same IDT.
	if (cpu_onboot())
  100f37:	e8 bb ff ff ff       	call   100ef7 <cpu_onboot>
  100f3c:	85 c0                	test   %eax,%eax
  100f3e:	74 05                	je     100f45 <trap_init+0x14>
		trap_init_idt();
  100f40:	e8 ca ff ff ff       	call   100f0f <trap_init_idt>

	// Load the IDT into this processor's IDT register.
	asm volatile("lidt %0" : : "m" (idt_pd));
  100f45:	0f 01 1d 00 60 10 00 	lidtl  0x106000

	// Check for the correct IDT and trap handler operation.
	if (cpu_onboot())
  100f4c:	e8 a6 ff ff ff       	call   100ef7 <cpu_onboot>
  100f51:	85 c0                	test   %eax,%eax
  100f53:	74 05                	je     100f5a <trap_init+0x29>
		trap_check_kernel();
  100f55:	e8 62 02 00 00       	call   1011bc <trap_check_kernel>
}
  100f5a:	c9                   	leave  
  100f5b:	c3                   	ret    

00100f5c <trap_name>:

const char *trap_name(int trapno)
{
  100f5c:	55                   	push   %ebp
  100f5d:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
  100f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  100f62:	83 f8 13             	cmp    $0x13,%eax
  100f65:	77 0c                	ja     100f73 <trap_name+0x17>
		return excnames[trapno];
  100f67:	8b 45 08             	mov    0x8(%ebp),%eax
  100f6a:	8b 04 85 e0 32 10 00 	mov    0x1032e0(,%eax,4),%eax
  100f71:	eb 05                	jmp    100f78 <trap_name+0x1c>
	return "(unknown trap)";
  100f73:	b8 41 2f 10 00       	mov    $0x102f41,%eax
}
  100f78:	5d                   	pop    %ebp
  100f79:	c3                   	ret    

00100f7a <trap_print_regs>:

void
trap_print_regs(pushregs *regs)
{
  100f7a:	55                   	push   %ebp
  100f7b:	89 e5                	mov    %esp,%ebp
  100f7d:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->edi);
  100f80:	8b 45 08             	mov    0x8(%ebp),%eax
  100f83:	8b 00                	mov    (%eax),%eax
  100f85:	89 44 24 04          	mov    %eax,0x4(%esp)
  100f89:	c7 04 24 50 2f 10 00 	movl   $0x102f50,(%esp)
  100f90:	e8 e0 13 00 00       	call   102375 <cprintf>
	cprintf("  esi  0x%08x\n", regs->esi);
  100f95:	8b 45 08             	mov    0x8(%ebp),%eax
  100f98:	8b 40 04             	mov    0x4(%eax),%eax
  100f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100f9f:	c7 04 24 5f 2f 10 00 	movl   $0x102f5f,(%esp)
  100fa6:	e8 ca 13 00 00       	call   102375 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->ebp);
  100fab:	8b 45 08             	mov    0x8(%ebp),%eax
  100fae:	8b 40 08             	mov    0x8(%eax),%eax
  100fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100fb5:	c7 04 24 6e 2f 10 00 	movl   $0x102f6e,(%esp)
  100fbc:	e8 b4 13 00 00       	call   102375 <cprintf>
//	cprintf("  oesp 0x%08x\n", regs->oesp);	don't print - useless
	cprintf("  ebx  0x%08x\n", regs->ebx);
  100fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  100fc4:	8b 40 10             	mov    0x10(%eax),%eax
  100fc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100fcb:	c7 04 24 7d 2f 10 00 	movl   $0x102f7d,(%esp)
  100fd2:	e8 9e 13 00 00       	call   102375 <cprintf>
	cprintf("  edx  0x%08x\n", regs->edx);
  100fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  100fda:	8b 40 14             	mov    0x14(%eax),%eax
  100fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100fe1:	c7 04 24 8c 2f 10 00 	movl   $0x102f8c,(%esp)
  100fe8:	e8 88 13 00 00       	call   102375 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->ecx);
  100fed:	8b 45 08             	mov    0x8(%ebp),%eax
  100ff0:	8b 40 18             	mov    0x18(%eax),%eax
  100ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ff7:	c7 04 24 9b 2f 10 00 	movl   $0x102f9b,(%esp)
  100ffe:	e8 72 13 00 00       	call   102375 <cprintf>
	cprintf("  eax  0x%08x\n", regs->eax);
  101003:	8b 45 08             	mov    0x8(%ebp),%eax
  101006:	8b 40 1c             	mov    0x1c(%eax),%eax
  101009:	89 44 24 04          	mov    %eax,0x4(%esp)
  10100d:	c7 04 24 aa 2f 10 00 	movl   $0x102faa,(%esp)
  101014:	e8 5c 13 00 00       	call   102375 <cprintf>
}
  101019:	c9                   	leave  
  10101a:	c3                   	ret    

0010101b <trap_print>:

void
trap_print(trapframe *tf)
{
  10101b:	55                   	push   %ebp
  10101c:	89 e5                	mov    %esp,%ebp
  10101e:	83 ec 18             	sub    $0x18,%esp
	cprintf("TRAP frame at %p\n", tf);
  101021:	8b 45 08             	mov    0x8(%ebp),%eax
  101024:	89 44 24 04          	mov    %eax,0x4(%esp)
  101028:	c7 04 24 b9 2f 10 00 	movl   $0x102fb9,(%esp)
  10102f:	e8 41 13 00 00       	call   102375 <cprintf>
	trap_print_regs(&tf->regs);
  101034:	8b 45 08             	mov    0x8(%ebp),%eax
  101037:	89 04 24             	mov    %eax,(%esp)
  10103a:	e8 3b ff ff ff       	call   100f7a <trap_print_regs>
	cprintf("  es   0x----%04x\n", tf->es);
  10103f:	8b 45 08             	mov    0x8(%ebp),%eax
  101042:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101046:	0f b7 c0             	movzwl %ax,%eax
  101049:	89 44 24 04          	mov    %eax,0x4(%esp)
  10104d:	c7 04 24 cb 2f 10 00 	movl   $0x102fcb,(%esp)
  101054:	e8 1c 13 00 00       	call   102375 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->ds);
  101059:	8b 45 08             	mov    0x8(%ebp),%eax
  10105c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101060:	0f b7 c0             	movzwl %ax,%eax
  101063:	89 44 24 04          	mov    %eax,0x4(%esp)
  101067:	c7 04 24 de 2f 10 00 	movl   $0x102fde,(%esp)
  10106e:	e8 02 13 00 00       	call   102375 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->trapno, trap_name(tf->trapno));
  101073:	8b 45 08             	mov    0x8(%ebp),%eax
  101076:	8b 40 30             	mov    0x30(%eax),%eax
  101079:	89 04 24             	mov    %eax,(%esp)
  10107c:	e8 db fe ff ff       	call   100f5c <trap_name>
  101081:	8b 55 08             	mov    0x8(%ebp),%edx
  101084:	8b 52 30             	mov    0x30(%edx),%edx
  101087:	89 44 24 08          	mov    %eax,0x8(%esp)
  10108b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10108f:	c7 04 24 f1 2f 10 00 	movl   $0x102ff1,(%esp)
  101096:	e8 da 12 00 00       	call   102375 <cprintf>
	cprintf("  err  0x%08x\n", tf->err);
  10109b:	8b 45 08             	mov    0x8(%ebp),%eax
  10109e:	8b 40 34             	mov    0x34(%eax),%eax
  1010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010a5:	c7 04 24 03 30 10 00 	movl   $0x103003,(%esp)
  1010ac:	e8 c4 12 00 00       	call   102375 <cprintf>
	cprintf("  eip  0x%08x\n", tf->eip);
  1010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b4:	8b 40 38             	mov    0x38(%eax),%eax
  1010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010bb:	c7 04 24 12 30 10 00 	movl   $0x103012,(%esp)
  1010c2:	e8 ae 12 00 00       	call   102375 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->cs);
  1010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1010ce:	0f b7 c0             	movzwl %ax,%eax
  1010d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010d5:	c7 04 24 21 30 10 00 	movl   $0x103021,(%esp)
  1010dc:	e8 94 12 00 00       	call   102375 <cprintf>
	cprintf("  flag 0x%08x\n", tf->eflags);
  1010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010e4:	8b 40 40             	mov    0x40(%eax),%eax
  1010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010eb:	c7 04 24 34 30 10 00 	movl   $0x103034,(%esp)
  1010f2:	e8 7e 12 00 00       	call   102375 <cprintf>
	cprintf("  esp  0x%08x\n", tf->esp);
  1010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1010fa:	8b 40 44             	mov    0x44(%eax),%eax
  1010fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101101:	c7 04 24 43 30 10 00 	movl   $0x103043,(%esp)
  101108:	e8 68 12 00 00       	call   102375 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->ss);
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101114:	0f b7 c0             	movzwl %ax,%eax
  101117:	89 44 24 04          	mov    %eax,0x4(%esp)
  10111b:	c7 04 24 52 30 10 00 	movl   $0x103052,(%esp)
  101122:	e8 4e 12 00 00       	call   102375 <cprintf>
}
  101127:	c9                   	leave  
  101128:	c3                   	ret    

00101129 <trap>:

void gcc_noreturn
trap(trapframe *tf)
{
  101129:	55                   	push   %ebp
  10112a:	89 e5                	mov    %esp,%ebp
  10112c:	83 ec 28             	sub    $0x28,%esp
	// The user-level environment may have set the DF flag,
	// and some versions of GCC rely on DF being clear.
	asm volatile("cld" ::: "cc");
  10112f:	fc                   	cld    

	// If this trap was anticipated, just use the designated handler.
	cpu *c = cpu_cur();
  101130:	e8 6f fd ff ff       	call   100ea4 <cpu_cur>
  101135:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (c->recover)
  101138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10113b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  101141:	85 c0                	test   %eax,%eax
  101143:	74 1e                	je     101163 <trap+0x3a>
		c->recover(tf, c->recoverdata);
  101145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101148:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  10114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101151:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  101157:	89 44 24 04          	mov    %eax,0x4(%esp)
  10115b:	8b 45 08             	mov    0x8(%ebp),%eax
  10115e:	89 04 24             	mov    %eax,(%esp)
  101161:	ff d2                	call   *%edx

	trap_print(tf);
  101163:	8b 45 08             	mov    0x8(%ebp),%eax
  101166:	89 04 24             	mov    %eax,(%esp)
  101169:	e8 ad fe ff ff       	call   10101b <trap_print>
	panic("unhandled trap");
  10116e:	c7 44 24 08 65 30 10 	movl   $0x103065,0x8(%esp)
  101175:	00 
  101176:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  10117d:	00 
  10117e:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  101185:	e8 a6 f1 ff ff       	call   100330 <debug_panic>

0010118a <trap_check_recover>:

// Helper function for trap_check_recover(), below:
// handles "anticipated" traps by simply resuming at a new EIP.
static void gcc_noreturn
trap_check_recover(trapframe *tf, void *recoverdata)
{
  10118a:	55                   	push   %ebp
  10118b:	89 e5                	mov    %esp,%ebp
  10118d:	83 ec 28             	sub    $0x28,%esp
	trap_check_args *args = recoverdata;
  101190:	8b 45 0c             	mov    0xc(%ebp),%eax
  101193:	89 45 f4             	mov    %eax,-0xc(%ebp)
	tf->eip = (uint32_t) args->reip;	// Use recovery EIP on return
  101196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101199:	8b 00                	mov    (%eax),%eax
  10119b:	89 c2                	mov    %eax,%edx
  10119d:	8b 45 08             	mov    0x8(%ebp),%eax
  1011a0:	89 50 38             	mov    %edx,0x38(%eax)
	args->trapno = tf->trapno;		// Return trap number
  1011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1011a6:	8b 40 30             	mov    0x30(%eax),%eax
  1011a9:	89 c2                	mov    %eax,%edx
  1011ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1011ae:	89 50 04             	mov    %edx,0x4(%eax)
	trap_return(tf);
  1011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1011b4:	89 04 24             	mov    %eax,(%esp)
  1011b7:	e8 34 03 00 00       	call   1014f0 <trap_return>

001011bc <trap_check_kernel>:

// Check for correct handling of traps from kernel mode.
// Called on the boot CPU after trap_init() and trap_setup().
void
trap_check_kernel(void)
{
  1011bc:	55                   	push   %ebp
  1011bd:	89 e5                	mov    %esp,%ebp
  1011bf:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  1011c2:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  1011c5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 0);	// better be in kernel mode!
  1011c9:	0f b7 c0             	movzwl %ax,%eax
  1011cc:	83 e0 03             	and    $0x3,%eax
  1011cf:	85 c0                	test   %eax,%eax
  1011d1:	74 24                	je     1011f7 <trap_check_kernel+0x3b>
  1011d3:	c7 44 24 0c 74 30 10 	movl   $0x103074,0xc(%esp)
  1011da:	00 
  1011db:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  1011e2:	00 
  1011e3:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  1011ea:	00 
  1011eb:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  1011f2:	e8 39 f1 ff ff       	call   100330 <debug_panic>

	cpu *c = cpu_cur();
  1011f7:	e8 a8 fc ff ff       	call   100ea4 <cpu_cur>
  1011fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	c->recover = trap_check_recover;
  1011ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101202:	c7 80 a0 00 00 00 8a 	movl   $0x10118a,0xa0(%eax)
  101209:	11 10 00 
	trap_check(&c->recoverdata);
  10120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10120f:	05 a4 00 00 00       	add    $0xa4,%eax
  101214:	89 04 24             	mov    %eax,(%esp)
  101217:	e8 96 00 00 00       	call   1012b2 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  10121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10121f:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  101226:	00 00 00 

	cprintf("trap_check_kernel() succeeded!\n");
  101229:	c7 04 24 8c 30 10 00 	movl   $0x10308c,(%esp)
  101230:	e8 40 11 00 00       	call   102375 <cprintf>
}
  101235:	c9                   	leave  
  101236:	c3                   	ret    

00101237 <trap_check_user>:
// Called from user() in kern/init.c, only in lab 1.
// We assume the "current cpu" is always the boot cpu;
// this true only because lab 1 doesn't start any other CPUs.
void
trap_check_user(void)
{
  101237:	55                   	push   %ebp
  101238:	89 e5                	mov    %esp,%ebp
  10123a:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  10123d:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  101240:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 3);	// better be in user mode!
  101244:	0f b7 c0             	movzwl %ax,%eax
  101247:	83 e0 03             	and    $0x3,%eax
  10124a:	83 f8 03             	cmp    $0x3,%eax
  10124d:	74 24                	je     101273 <trap_check_user+0x3c>
  10124f:	c7 44 24 0c ac 30 10 	movl   $0x1030ac,0xc(%esp)
  101256:	00 
  101257:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  10125e:	00 
  10125f:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  101266:	00 
  101267:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  10126e:	e8 bd f0 ff ff       	call   100330 <debug_panic>

	cpu *c = &cpu_boot;	// cpu_cur doesn't work from user mode!
  101273:	c7 45 f0 00 50 10 00 	movl   $0x105000,-0x10(%ebp)
	c->recover = trap_check_recover;
  10127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10127d:	c7 80 a0 00 00 00 8a 	movl   $0x10118a,0xa0(%eax)
  101284:	11 10 00 
	trap_check(&c->recoverdata);
  101287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10128a:	05 a4 00 00 00       	add    $0xa4,%eax
  10128f:	89 04 24             	mov    %eax,(%esp)
  101292:	e8 1b 00 00 00       	call   1012b2 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  101297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10129a:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  1012a1:	00 00 00 

	cprintf("trap_check_user() succeeded!\n");
  1012a4:	c7 04 24 c1 30 10 00 	movl   $0x1030c1,(%esp)
  1012ab:	e8 c5 10 00 00       	call   102375 <cprintf>
}
  1012b0:	c9                   	leave  
  1012b1:	c3                   	ret    

001012b2 <trap_check>:
void after_priv();

// Multi-purpose trap checking function.
void
trap_check(void **argsp)
{
  1012b2:	55                   	push   %ebp
  1012b3:	89 e5                	mov    %esp,%ebp
  1012b5:	57                   	push   %edi
  1012b6:	56                   	push   %esi
  1012b7:	53                   	push   %ebx
  1012b8:	83 ec 3c             	sub    $0x3c,%esp
	volatile int cookie = 0xfeedface;
  1012bb:	c7 45 e0 ce fa ed fe 	movl   $0xfeedface,-0x20(%ebp)
	volatile trap_check_args args;
	*argsp = (void*)&args;	// provide args needed for trap recovery
  1012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1012c5:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1012c8:	89 10                	mov    %edx,(%eax)

	// Try a divide by zero trap.
	// Be careful when using && to take the address of a label:
	// some versions of GCC (4.4.2 at least) will incorrectly try to
	// eliminate code it thinks is _only_ reachable via such a pointer.
	args.reip = after_div0;
  1012ca:	c7 45 d8 d8 12 10 00 	movl   $0x1012d8,-0x28(%ebp)
	asm volatile("div %0,%0; after_div0:" : : "r" (0));
  1012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  1012d6:	f7 f0                	div    %eax

001012d8 <after_div0>:
	assert(args.trapno == T_DIVIDE);
  1012d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1012db:	85 c0                	test   %eax,%eax
  1012dd:	74 24                	je     101303 <after_div0+0x2b>
  1012df:	c7 44 24 0c df 30 10 	movl   $0x1030df,0xc(%esp)
  1012e6:	00 
  1012e7:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  1012ee:	00 
  1012ef:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  1012f6:	00 
  1012f7:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  1012fe:	e8 2d f0 ff ff       	call   100330 <debug_panic>

	// Make sure we got our correct stack back with us.
	// The asm ensures gcc uses ebp/esp to get the cookie.
	asm volatile("" : : : "eax","ebx","ecx","edx","esi","edi");
	assert(cookie == 0xfeedface);
  101303:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101306:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  10130b:	74 24                	je     101331 <after_div0+0x59>
  10130d:	c7 44 24 0c f7 30 10 	movl   $0x1030f7,0xc(%esp)
  101314:	00 
  101315:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  10131c:	00 
  10131d:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  101324:	00 
  101325:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  10132c:	e8 ff ef ff ff       	call   100330 <debug_panic>

	// Breakpoint trap
	args.reip = after_breakpoint;
  101331:	c7 45 d8 39 13 10 00 	movl   $0x101339,-0x28(%ebp)
	asm volatile("int3; after_breakpoint:");
  101338:	cc                   	int3   

00101339 <after_breakpoint>:
	assert(args.trapno == T_BRKPT);
  101339:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10133c:	83 f8 03             	cmp    $0x3,%eax
  10133f:	74 24                	je     101365 <after_breakpoint+0x2c>
  101341:	c7 44 24 0c 0c 31 10 	movl   $0x10310c,0xc(%esp)
  101348:	00 
  101349:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  101350:	00 
  101351:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  101358:	00 
  101359:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  101360:	e8 cb ef ff ff       	call   100330 <debug_panic>

	// Overflow trap
	args.reip = after_overflow;
  101365:	c7 45 d8 74 13 10 00 	movl   $0x101374,-0x28(%ebp)
	asm volatile("addl %0,%0; into; after_overflow:" : : "r" (0x70000000));
  10136c:	b8 00 00 00 70       	mov    $0x70000000,%eax
  101371:	01 c0                	add    %eax,%eax
  101373:	ce                   	into   

00101374 <after_overflow>:
	assert(args.trapno == T_OFLOW);
  101374:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101377:	83 f8 04             	cmp    $0x4,%eax
  10137a:	74 24                	je     1013a0 <after_overflow+0x2c>
  10137c:	c7 44 24 0c 23 31 10 	movl   $0x103123,0xc(%esp)
  101383:	00 
  101384:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  10138b:	00 
  10138c:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  101393:	00 
  101394:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  10139b:	e8 90 ef ff ff       	call   100330 <debug_panic>

	// Bounds trap
	args.reip = after_bound;
  1013a0:	c7 45 d8 bd 13 10 00 	movl   $0x1013bd,-0x28(%ebp)
	int bounds[2] = { 1, 3 };
  1013a7:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1013ae:	c7 45 d4 03 00 00 00 	movl   $0x3,-0x2c(%ebp)
	asm volatile("boundl %0,%1; after_bound:" : : "r" (0), "m" (bounds[0]));
  1013b5:	b8 00 00 00 00       	mov    $0x0,%eax
  1013ba:	62 45 d0             	bound  %eax,-0x30(%ebp)

001013bd <after_bound>:
	assert(args.trapno == T_BOUND);
  1013bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1013c0:	83 f8 05             	cmp    $0x5,%eax
  1013c3:	74 24                	je     1013e9 <after_bound+0x2c>
  1013c5:	c7 44 24 0c 3a 31 10 	movl   $0x10313a,0xc(%esp)
  1013cc:	00 
  1013cd:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  1013d4:	00 
  1013d5:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  1013dc:	00 
  1013dd:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  1013e4:	e8 47 ef ff ff       	call   100330 <debug_panic>

	// Illegal instruction trap
	args.reip = after_illegal;
  1013e9:	c7 45 d8 f2 13 10 00 	movl   $0x1013f2,-0x28(%ebp)
	asm volatile("ud2; after_illegal:");	// guaranteed to be undefined
  1013f0:	0f 0b                	ud2    

001013f2 <after_illegal>:
	assert(args.trapno == T_ILLOP);
  1013f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1013f5:	83 f8 06             	cmp    $0x6,%eax
  1013f8:	74 24                	je     10141e <after_illegal+0x2c>
  1013fa:	c7 44 24 0c 51 31 10 	movl   $0x103151,0xc(%esp)
  101401:	00 
  101402:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  101409:	00 
  10140a:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  101411:	00 
  101412:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  101419:	e8 12 ef ff ff       	call   100330 <debug_panic>

	// General protection fault due to invalid segment load
	args.reip = after_gpfault;
  10141e:	c7 45 d8 2c 14 10 00 	movl   $0x10142c,-0x28(%ebp)
	asm volatile("movl %0,%%fs; after_gpfault:" : : "r" (-1));
  101425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10142a:	8e e0                	mov    %eax,%fs

0010142c <after_gpfault>:
	assert(args.trapno == T_GPFLT);
  10142c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10142f:	83 f8 0d             	cmp    $0xd,%eax
  101432:	74 24                	je     101458 <after_gpfault+0x2c>
  101434:	c7 44 24 0c 68 31 10 	movl   $0x103168,0xc(%esp)
  10143b:	00 
  10143c:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  101443:	00 
  101444:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  10144b:	00 
  10144c:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  101453:	e8 d8 ee ff ff       	call   100330 <debug_panic>

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  101458:	8c 4d e6             	mov    %cs,-0x1a(%ebp)
        return cs;
  10145b:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax

	// General protection fault due to privilege violation
	if (read_cs() & 3) {
  10145f:	0f b7 c0             	movzwl %ax,%eax
  101462:	83 e0 03             	and    $0x3,%eax
  101465:	85 c0                	test   %eax,%eax
  101467:	74 3a                	je     1014a3 <after_priv+0x2c>
		args.reip = after_priv;
  101469:	c7 45 d8 77 14 10 00 	movl   $0x101477,-0x28(%ebp)
		asm volatile("lidt %0; after_priv:" : : "m" (idt_pd));
  101470:	0f 01 1d 00 60 10 00 	lidtl  0x106000

00101477 <after_priv>:
		assert(args.trapno == T_GPFLT);
  101477:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10147a:	83 f8 0d             	cmp    $0xd,%eax
  10147d:	74 24                	je     1014a3 <after_priv+0x2c>
  10147f:	c7 44 24 0c 68 31 10 	movl   $0x103168,0xc(%esp)
  101486:	00 
  101487:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  10148e:	00 
  10148f:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  101496:	00 
  101497:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  10149e:	e8 8d ee ff ff       	call   100330 <debug_panic>
	}

	// Make sure our stack cookie is still with us
	assert(cookie == 0xfeedface);
  1014a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1014a6:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  1014ab:	74 24                	je     1014d1 <after_priv+0x5a>
  1014ad:	c7 44 24 0c f7 30 10 	movl   $0x1030f7,0xc(%esp)
  1014b4:	00 
  1014b5:	c7 44 24 08 f6 2e 10 	movl   $0x102ef6,0x8(%esp)
  1014bc:	00 
  1014bd:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  1014c4:	00 
  1014c5:	c7 04 24 35 2f 10 00 	movl   $0x102f35,(%esp)
  1014cc:	e8 5f ee ff ff       	call   100330 <debug_panic>

	*argsp = NULL;	// recovery mechanism not needed anymore
  1014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1014d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  1014da:	83 c4 3c             	add    $0x3c,%esp
  1014dd:	5b                   	pop    %ebx
  1014de:	5e                   	pop    %esi
  1014df:	5f                   	pop    %edi
  1014e0:	5d                   	pop    %ebp
  1014e1:	c3                   	ret    
  1014e2:	90                   	nop
  1014e3:	90                   	nop
  1014e4:	90                   	nop
  1014e5:	90                   	nop
  1014e6:	90                   	nop
  1014e7:	90                   	nop
  1014e8:	90                   	nop
  1014e9:	90                   	nop
  1014ea:	90                   	nop
  1014eb:	90                   	nop
  1014ec:	90                   	nop
  1014ed:	90                   	nop
  1014ee:	90                   	nop
  1014ef:	90                   	nop

001014f0 <trap_return>:
.p2align 4, 0x90		/* 16-byte alignment, nop filled */
trap_return:
/*
 * Lab 1: Your code here for trap_return
 */
1:	jmp	1b		// just spin
  1014f0:	eb fe                	jmp    1014f0 <trap_return>
  1014f2:	90                   	nop
  1014f3:	90                   	nop

001014f4 <video_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
video_init(void)
{
  1014f4:	55                   	push   %ebp
  1014f5:	89 e5                	mov    %esp,%ebp
  1014f7:	83 ec 30             	sub    $0x30,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	/* Get a pointer to the memory-mapped text display buffer. */
	cp = (uint16_t*) mem_ptr(CGA_BUF);
  1014fa:	c7 45 d8 00 80 0b 00 	movl   $0xb8000,-0x28(%ebp)
	was = *cp;
  101501:	8b 45 d8             	mov    -0x28(%ebp),%eax
  101504:	0f b7 00             	movzwl (%eax),%eax
  101507:	66 89 45 de          	mov    %ax,-0x22(%ebp)
	*cp = (uint16_t) 0xA55A;
  10150b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10150e:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
  101513:	8b 45 d8             	mov    -0x28(%ebp),%eax
  101516:	0f b7 00             	movzwl (%eax),%eax
  101519:	66 3d 5a a5          	cmp    $0xa55a,%ax
  10151d:	74 13                	je     101532 <video_init+0x3e>
		cp = (uint16_t*) mem_ptr(MONO_BUF);
  10151f:	c7 45 d8 00 00 0b 00 	movl   $0xb0000,-0x28(%ebp)
		addr_6845 = MONO_BASE;
  101526:	c7 05 60 7f 10 00 b4 	movl   $0x3b4,0x107f60
  10152d:	03 00 00 
  101530:	eb 14                	jmp    101546 <video_init+0x52>
	} else {
		*cp = was;
  101532:	8b 45 d8             	mov    -0x28(%ebp),%eax
  101535:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101539:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
  10153c:	c7 05 60 7f 10 00 d4 	movl   $0x3d4,0x107f60
  101543:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
  101546:	a1 60 7f 10 00       	mov    0x107f60,%eax
  10154b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10154e:	c6 45 e7 0e          	movb   $0xe,-0x19(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101552:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101556:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  10155a:	a1 60 7f 10 00       	mov    0x107f60,%eax
  10155f:	83 c0 01             	add    $0x1,%eax
  101562:	89 45 ec             	mov    %eax,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101565:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101568:	89 c2                	mov    %eax,%edx
  10156a:	ec                   	in     (%dx),%al
  10156b:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  10156e:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  101572:	0f b6 c0             	movzbl %al,%eax
  101575:	c1 e0 08             	shl    $0x8,%eax
  101578:	89 45 e0             	mov    %eax,-0x20(%ebp)
	outb(addr_6845, 15);
  10157b:	a1 60 7f 10 00       	mov    0x107f60,%eax
  101580:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101583:	c6 45 f3 0f          	movb   $0xf,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101587:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10158b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10158e:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
  10158f:	a1 60 7f 10 00       	mov    0x107f60,%eax
  101594:	83 c0 01             	add    $0x1,%eax
  101597:	89 45 f8             	mov    %eax,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  10159a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10159d:	89 c2                	mov    %eax,%edx
  10159f:	ec                   	in     (%dx),%al
  1015a0:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  1015a3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
  1015a7:	0f b6 c0             	movzbl %al,%eax
  1015aa:	09 45 e0             	or     %eax,-0x20(%ebp)

	crt_buf = (uint16_t*) cp;
  1015ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1015b0:	a3 64 7f 10 00       	mov    %eax,0x107f64
	crt_pos = pos;
  1015b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1015b8:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
}
  1015be:	c9                   	leave  
  1015bf:	c3                   	ret    

001015c0 <video_putc>:



void
video_putc(int c)
{
  1015c0:	55                   	push   %ebp
  1015c1:	89 e5                	mov    %esp,%ebp
  1015c3:	53                   	push   %ebx
  1015c4:	83 ec 44             	sub    $0x44,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
  1015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1015ca:	b0 00                	mov    $0x0,%al
  1015cc:	85 c0                	test   %eax,%eax
  1015ce:	75 07                	jne    1015d7 <video_putc+0x17>
		c |= 0x0700;
  1015d0:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
  1015d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1015da:	25 ff 00 00 00       	and    $0xff,%eax
  1015df:	83 f8 09             	cmp    $0x9,%eax
  1015e2:	0f 84 ae 00 00 00    	je     101696 <video_putc+0xd6>
  1015e8:	83 f8 09             	cmp    $0x9,%eax
  1015eb:	7f 0a                	jg     1015f7 <video_putc+0x37>
  1015ed:	83 f8 08             	cmp    $0x8,%eax
  1015f0:	74 14                	je     101606 <video_putc+0x46>
  1015f2:	e9 dd 00 00 00       	jmp    1016d4 <video_putc+0x114>
  1015f7:	83 f8 0a             	cmp    $0xa,%eax
  1015fa:	74 4e                	je     10164a <video_putc+0x8a>
  1015fc:	83 f8 0d             	cmp    $0xd,%eax
  1015ff:	74 59                	je     10165a <video_putc+0x9a>
  101601:	e9 ce 00 00 00       	jmp    1016d4 <video_putc+0x114>
	case '\b':
		if (crt_pos > 0) {
  101606:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10160d:	66 85 c0             	test   %ax,%ax
  101610:	0f 84 e4 00 00 00    	je     1016fa <video_putc+0x13a>
			crt_pos--;
  101616:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10161d:	83 e8 01             	sub    $0x1,%eax
  101620:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101626:	a1 64 7f 10 00       	mov    0x107f64,%eax
  10162b:	0f b7 15 68 7f 10 00 	movzwl 0x107f68,%edx
  101632:	0f b7 d2             	movzwl %dx,%edx
  101635:	01 d2                	add    %edx,%edx
  101637:	8d 14 10             	lea    (%eax,%edx,1),%edx
  10163a:	8b 45 08             	mov    0x8(%ebp),%eax
  10163d:	b0 00                	mov    $0x0,%al
  10163f:	83 c8 20             	or     $0x20,%eax
  101642:	66 89 02             	mov    %ax,(%edx)
		}
		break;
  101645:	e9 b1 00 00 00       	jmp    1016fb <video_putc+0x13b>
	case '\n':
		crt_pos += CRT_COLS;
  10164a:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  101651:	83 c0 50             	add    $0x50,%eax
  101654:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  10165a:	0f b7 1d 68 7f 10 00 	movzwl 0x107f68,%ebx
  101661:	0f b7 0d 68 7f 10 00 	movzwl 0x107f68,%ecx
  101668:	0f b7 c1             	movzwl %cx,%eax
  10166b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101671:	c1 e8 10             	shr    $0x10,%eax
  101674:	89 c2                	mov    %eax,%edx
  101676:	66 c1 ea 06          	shr    $0x6,%dx
  10167a:	89 d0                	mov    %edx,%eax
  10167c:	c1 e0 02             	shl    $0x2,%eax
  10167f:	01 d0                	add    %edx,%eax
  101681:	c1 e0 04             	shl    $0x4,%eax
  101684:	89 ca                	mov    %ecx,%edx
  101686:	66 29 c2             	sub    %ax,%dx
  101689:	89 d8                	mov    %ebx,%eax
  10168b:	66 29 d0             	sub    %dx,%ax
  10168e:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
		break;
  101694:	eb 65                	jmp    1016fb <video_putc+0x13b>
	case '\t':
		video_putc(' ');
  101696:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10169d:	e8 1e ff ff ff       	call   1015c0 <video_putc>
		video_putc(' ');
  1016a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016a9:	e8 12 ff ff ff       	call   1015c0 <video_putc>
		video_putc(' ');
  1016ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016b5:	e8 06 ff ff ff       	call   1015c0 <video_putc>
		video_putc(' ');
  1016ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016c1:	e8 fa fe ff ff       	call   1015c0 <video_putc>
		video_putc(' ');
  1016c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016cd:	e8 ee fe ff ff       	call   1015c0 <video_putc>
		break;
  1016d2:	eb 27                	jmp    1016fb <video_putc+0x13b>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  1016d4:	8b 15 64 7f 10 00    	mov    0x107f64,%edx
  1016da:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  1016e1:	0f b7 c8             	movzwl %ax,%ecx
  1016e4:	01 c9                	add    %ecx,%ecx
  1016e6:	8d 0c 0a             	lea    (%edx,%ecx,1),%ecx
  1016e9:	8b 55 08             	mov    0x8(%ebp),%edx
  1016ec:	66 89 11             	mov    %dx,(%ecx)
  1016ef:	83 c0 01             	add    $0x1,%eax
  1016f2:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
  1016f8:	eb 01                	jmp    1016fb <video_putc+0x13b>
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
  1016fa:	90                   	nop
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  1016fb:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  101702:	66 3d cf 07          	cmp    $0x7cf,%ax
  101706:	76 5b                	jbe    101763 <video_putc+0x1a3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
  101708:	a1 64 7f 10 00       	mov    0x107f64,%eax
  10170d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101713:	a1 64 7f 10 00       	mov    0x107f64,%eax
  101718:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10171f:	00 
  101720:	89 54 24 04          	mov    %edx,0x4(%esp)
  101724:	89 04 24             	mov    %eax,(%esp)
  101727:	e8 a4 0e 00 00       	call   1025d0 <memmove>
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  10172c:	c7 45 d4 80 07 00 00 	movl   $0x780,-0x2c(%ebp)
  101733:	eb 15                	jmp    10174a <video_putc+0x18a>
			crt_buf[i] = 0x0700 | ' ';
  101735:	a1 64 7f 10 00       	mov    0x107f64,%eax
  10173a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10173d:	01 d2                	add    %edx,%edx
  10173f:	01 d0                	add    %edx,%eax
  101741:	66 c7 00 20 07       	movw   $0x720,(%eax)
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  101746:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
  10174a:	81 7d d4 cf 07 00 00 	cmpl   $0x7cf,-0x2c(%ebp)
  101751:	7e e2                	jle    101735 <video_putc+0x175>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  101753:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10175a:	83 e8 50             	sub    $0x50,%eax
  10175d:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  101763:	a1 60 7f 10 00       	mov    0x107f60,%eax
  101768:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10176b:	c6 45 db 0e          	movb   $0xe,-0x25(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  10176f:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  101773:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101776:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  101777:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10177e:	66 c1 e8 08          	shr    $0x8,%ax
  101782:	0f b6 c0             	movzbl %al,%eax
  101785:	8b 15 60 7f 10 00    	mov    0x107f60,%edx
  10178b:	83 c2 01             	add    $0x1,%edx
  10178e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  101791:	88 45 e3             	mov    %al,-0x1d(%ebp)
  101794:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101798:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10179b:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
  10179c:	a1 60 7f 10 00       	mov    0x107f60,%eax
  1017a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1017a4:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
  1017a8:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1017ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1017af:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
  1017b0:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  1017b7:	0f b6 c0             	movzbl %al,%eax
  1017ba:	8b 15 60 7f 10 00    	mov    0x107f60,%edx
  1017c0:	83 c2 01             	add    $0x1,%edx
  1017c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1017c6:	88 45 f3             	mov    %al,-0xd(%ebp)
  1017c9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1017cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1017d0:	ee                   	out    %al,(%dx)
}
  1017d1:	83 c4 44             	add    $0x44,%esp
  1017d4:	5b                   	pop    %ebx
  1017d5:	5d                   	pop    %ebp
  1017d6:	c3                   	ret    
  1017d7:	90                   	nop

001017d8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  1017d8:	55                   	push   %ebp
  1017d9:	89 e5                	mov    %esp,%ebp
  1017db:	83 ec 38             	sub    $0x38,%esp
  1017de:	c7 45 e4 64 00 00 00 	movl   $0x64,-0x1c(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1017e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1017e8:	89 c2                	mov    %eax,%edx
  1017ea:	ec                   	in     (%dx),%al
  1017eb:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
  1017ee:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  1017f2:	0f b6 c0             	movzbl %al,%eax
  1017f5:	83 e0 01             	and    $0x1,%eax
  1017f8:	85 c0                	test   %eax,%eax
  1017fa:	75 0a                	jne    101806 <kbd_proc_data+0x2e>
		return -1;
  1017fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101801:	e9 5a 01 00 00       	jmp    101960 <kbd_proc_data+0x188>
  101806:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  10180d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101810:	89 c2                	mov    %eax,%edx
  101812:	ec                   	in     (%dx),%al
  101813:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  101816:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax

	data = inb(KBDATAP);
  10181a:	88 45 e3             	mov    %al,-0x1d(%ebp)

	if (data == 0xE0) {
  10181d:	80 7d e3 e0          	cmpb   $0xe0,-0x1d(%ebp)
  101821:	75 17                	jne    10183a <kbd_proc_data+0x62>
		// E0 escape character
		shift |= E0ESC;
  101823:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  101828:	83 c8 40             	or     $0x40,%eax
  10182b:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
		return 0;
  101830:	b8 00 00 00 00       	mov    $0x0,%eax
  101835:	e9 26 01 00 00       	jmp    101960 <kbd_proc_data+0x188>
	} else if (data & 0x80) {
  10183a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10183e:	84 c0                	test   %al,%al
  101840:	79 47                	jns    101889 <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  101842:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  101847:	83 e0 40             	and    $0x40,%eax
  10184a:	85 c0                	test   %eax,%eax
  10184c:	75 09                	jne    101857 <kbd_proc_data+0x7f>
  10184e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101852:	83 e0 7f             	and    $0x7f,%eax
  101855:	eb 04                	jmp    10185b <kbd_proc_data+0x83>
  101857:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10185b:	88 45 e3             	mov    %al,-0x1d(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
  10185e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101862:	0f b6 80 20 60 10 00 	movzbl 0x106020(%eax),%eax
  101869:	83 c8 40             	or     $0x40,%eax
  10186c:	0f b6 c0             	movzbl %al,%eax
  10186f:	f7 d0                	not    %eax
  101871:	89 c2                	mov    %eax,%edx
  101873:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  101878:	21 d0                	and    %edx,%eax
  10187a:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
		return 0;
  10187f:	b8 00 00 00 00       	mov    $0x0,%eax
  101884:	e9 d7 00 00 00       	jmp    101960 <kbd_proc_data+0x188>
	} else if (shift & E0ESC) {
  101889:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  10188e:	83 e0 40             	and    $0x40,%eax
  101891:	85 c0                	test   %eax,%eax
  101893:	74 11                	je     1018a6 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  101895:	80 4d e3 80          	orb    $0x80,-0x1d(%ebp)
		shift &= ~E0ESC;
  101899:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  10189e:	83 e0 bf             	and    $0xffffffbf,%eax
  1018a1:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
	}

	shift |= shiftcode[data];
  1018a6:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1018aa:	0f b6 80 20 60 10 00 	movzbl 0x106020(%eax),%eax
  1018b1:	0f b6 d0             	movzbl %al,%edx
  1018b4:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018b9:	09 d0                	or     %edx,%eax
  1018bb:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
	shift ^= togglecode[data];
  1018c0:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1018c4:	0f b6 80 20 61 10 00 	movzbl 0x106120(%eax),%eax
  1018cb:	0f b6 d0             	movzbl %al,%edx
  1018ce:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018d3:	31 d0                	xor    %edx,%eax
  1018d5:	a3 6c 7f 10 00       	mov    %eax,0x107f6c

	c = charcode[shift & (CTL | SHIFT)][data];
  1018da:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018df:	83 e0 03             	and    $0x3,%eax
  1018e2:	8b 14 85 20 65 10 00 	mov    0x106520(,%eax,4),%edx
  1018e9:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1018ed:	8d 04 02             	lea    (%edx,%eax,1),%eax
  1018f0:	0f b6 00             	movzbl (%eax),%eax
  1018f3:	0f b6 c0             	movzbl %al,%eax
  1018f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	if (shift & CAPSLOCK) {
  1018f9:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018fe:	83 e0 08             	and    $0x8,%eax
  101901:	85 c0                	test   %eax,%eax
  101903:	74 22                	je     101927 <kbd_proc_data+0x14f>
		if ('a' <= c && c <= 'z')
  101905:	83 7d dc 60          	cmpl   $0x60,-0x24(%ebp)
  101909:	7e 0c                	jle    101917 <kbd_proc_data+0x13f>
  10190b:	83 7d dc 7a          	cmpl   $0x7a,-0x24(%ebp)
  10190f:	7f 06                	jg     101917 <kbd_proc_data+0x13f>
			c += 'A' - 'a';
  101911:	83 6d dc 20          	subl   $0x20,-0x24(%ebp)
	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
  101915:	eb 10                	jmp    101927 <kbd_proc_data+0x14f>
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
  101917:	83 7d dc 40          	cmpl   $0x40,-0x24(%ebp)
  10191b:	7e 0a                	jle    101927 <kbd_proc_data+0x14f>
  10191d:	83 7d dc 5a          	cmpl   $0x5a,-0x24(%ebp)
  101921:	7f 04                	jg     101927 <kbd_proc_data+0x14f>
			c += 'a' - 'A';
  101923:	83 45 dc 20          	addl   $0x20,-0x24(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101927:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  10192c:	f7 d0                	not    %eax
  10192e:	83 e0 06             	and    $0x6,%eax
  101931:	85 c0                	test   %eax,%eax
  101933:	75 28                	jne    10195d <kbd_proc_data+0x185>
  101935:	81 7d dc e9 00 00 00 	cmpl   $0xe9,-0x24(%ebp)
  10193c:	75 1f                	jne    10195d <kbd_proc_data+0x185>
		cprintf("Rebooting!\n");
  10193e:	c7 04 24 30 33 10 00 	movl   $0x103330,(%esp)
  101945:	e8 2b 0a 00 00       	call   102375 <cprintf>
  10194a:	c7 45 f4 92 00 00 00 	movl   $0x92,-0xc(%ebp)
  101951:	c6 45 f3 03          	movb   $0x3,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101955:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101959:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10195c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
  10195d:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  101960:	c9                   	leave  
  101961:	c3                   	ret    

00101962 <kbd_intr>:

void
kbd_intr(void)
{
  101962:	55                   	push   %ebp
  101963:	89 e5                	mov    %esp,%ebp
  101965:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
  101968:	c7 04 24 d8 17 10 00 	movl   $0x1017d8,(%esp)
  10196f:	e8 83 e8 ff ff       	call   1001f7 <cons_intr>
}
  101974:	c9                   	leave  
  101975:	c3                   	ret    

00101976 <kbd_init>:

void
kbd_init(void)
{
  101976:	55                   	push   %ebp
  101977:	89 e5                	mov    %esp,%ebp
}
  101979:	5d                   	pop    %ebp
  10197a:	c3                   	ret    
  10197b:	90                   	nop

0010197c <delay>:


// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  10197c:	55                   	push   %ebp
  10197d:	89 e5                	mov    %esp,%ebp
  10197f:	83 ec 20             	sub    $0x20,%esp
  101982:	c7 45 e0 84 00 00 00 	movl   $0x84,-0x20(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101989:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10198c:	89 c2                	mov    %eax,%edx
  10198e:	ec                   	in     (%dx),%al
  10198f:	88 45 e7             	mov    %al,-0x19(%ebp)
	return data;
  101992:	c7 45 e8 84 00 00 00 	movl   $0x84,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101999:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10199c:	89 c2                	mov    %eax,%edx
  10199e:	ec                   	in     (%dx),%al
  10199f:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  1019a2:	c7 45 f0 84 00 00 00 	movl   $0x84,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1019ac:	89 c2                	mov    %eax,%edx
  1019ae:	ec                   	in     (%dx),%al
  1019af:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  1019b2:	c7 45 f8 84 00 00 00 	movl   $0x84,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019bc:	89 c2                	mov    %eax,%edx
  1019be:	ec                   	in     (%dx),%al
  1019bf:	88 45 ff             	mov    %al,-0x1(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  1019c2:	c9                   	leave  
  1019c3:	c3                   	ret    

001019c4 <serial_proc_data>:

static int
serial_proc_data(void)
{
  1019c4:	55                   	push   %ebp
  1019c5:	89 e5                	mov    %esp,%ebp
  1019c7:	83 ec 10             	sub    $0x10,%esp
  1019ca:	c7 45 f0 fd 03 00 00 	movl   $0x3fd,-0x10(%ebp)
  1019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1019d4:	89 c2                	mov    %eax,%edx
  1019d6:	ec                   	in     (%dx),%al
  1019d7:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  1019da:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  1019de:	0f b6 c0             	movzbl %al,%eax
  1019e1:	83 e0 01             	and    $0x1,%eax
  1019e4:	85 c0                	test   %eax,%eax
  1019e6:	75 07                	jne    1019ef <serial_proc_data+0x2b>
		return -1;
  1019e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1019ed:	eb 17                	jmp    101a06 <serial_proc_data+0x42>
  1019ef:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019f9:	89 c2                	mov    %eax,%edx
  1019fb:	ec                   	in     (%dx),%al
  1019fc:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  1019ff:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(COM1+COM_RX);
  101a03:	0f b6 c0             	movzbl %al,%eax
}
  101a06:	c9                   	leave  
  101a07:	c3                   	ret    

00101a08 <serial_intr>:

void
serial_intr(void)
{
  101a08:	55                   	push   %ebp
  101a09:	89 e5                	mov    %esp,%ebp
  101a0b:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
  101a0e:	a1 80 7f 10 00       	mov    0x107f80,%eax
  101a13:	85 c0                	test   %eax,%eax
  101a15:	74 0c                	je     101a23 <serial_intr+0x1b>
		cons_intr(serial_proc_data);
  101a17:	c7 04 24 c4 19 10 00 	movl   $0x1019c4,(%esp)
  101a1e:	e8 d4 e7 ff ff       	call   1001f7 <cons_intr>
}
  101a23:	c9                   	leave  
  101a24:	c3                   	ret    

00101a25 <serial_putc>:

void
serial_putc(int c)
{
  101a25:	55                   	push   %ebp
  101a26:	89 e5                	mov    %esp,%ebp
  101a28:	83 ec 10             	sub    $0x10,%esp
	if (!serial_exists)
  101a2b:	a1 80 7f 10 00       	mov    0x107f80,%eax
  101a30:	85 c0                	test   %eax,%eax
  101a32:	74 53                	je     101a87 <serial_putc+0x62>
		return;

	int i;
	for (i = 0;
  101a34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  101a3b:	eb 09                	jmp    101a46 <serial_putc+0x21>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  101a3d:	e8 3a ff ff ff       	call   10197c <delay>
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
  101a42:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  101a46:	c7 45 f4 fd 03 00 00 	movl   $0x3fd,-0xc(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101a50:	89 c2                	mov    %eax,%edx
  101a52:	ec                   	in     (%dx),%al
  101a53:	88 45 fa             	mov    %al,-0x6(%ebp)
	return data;
  101a56:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  101a5a:	0f b6 c0             	movzbl %al,%eax
  101a5d:	83 e0 20             	and    $0x20,%eax
{
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
  101a60:	85 c0                	test   %eax,%eax
  101a62:	75 09                	jne    101a6d <serial_putc+0x48>
  101a64:	81 7d f0 ff 31 00 00 	cmpl   $0x31ff,-0x10(%ebp)
  101a6b:	7e d0                	jle    101a3d <serial_putc+0x18>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
  101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a70:	0f b6 c0             	movzbl %al,%eax
  101a73:	c7 45 fc f8 03 00 00 	movl   $0x3f8,-0x4(%ebp)
  101a7a:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101a7d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101a81:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101a84:	ee                   	out    %al,(%dx)
  101a85:	eb 01                	jmp    101a88 <serial_putc+0x63>

void
serial_putc(int c)
{
	if (!serial_exists)
		return;
  101a87:	90                   	nop
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
}
  101a88:	c9                   	leave  
  101a89:	c3                   	ret    

00101a8a <serial_init>:

void
serial_init(void)
{
  101a8a:	55                   	push   %ebp
  101a8b:	89 e5                	mov    %esp,%ebp
  101a8d:	83 ec 50             	sub    $0x50,%esp
  101a90:	c7 45 b4 fa 03 00 00 	movl   $0x3fa,-0x4c(%ebp)
  101a97:	c6 45 b3 00          	movb   $0x0,-0x4d(%ebp)
  101a9b:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
  101a9f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  101aa2:	ee                   	out    %al,(%dx)
  101aa3:	c7 45 bc fb 03 00 00 	movl   $0x3fb,-0x44(%ebp)
  101aaa:	c6 45 bb 80          	movb   $0x80,-0x45(%ebp)
  101aae:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
  101ab2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  101ab5:	ee                   	out    %al,(%dx)
  101ab6:	c7 45 c4 f8 03 00 00 	movl   $0x3f8,-0x3c(%ebp)
  101abd:	c6 45 c3 0c          	movb   $0xc,-0x3d(%ebp)
  101ac1:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
  101ac5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  101ac8:	ee                   	out    %al,(%dx)
  101ac9:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%ebp)
  101ad0:	c6 45 cb 00          	movb   $0x0,-0x35(%ebp)
  101ad4:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
  101ad8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  101adb:	ee                   	out    %al,(%dx)
  101adc:	c7 45 d4 fb 03 00 00 	movl   $0x3fb,-0x2c(%ebp)
  101ae3:	c6 45 d3 03          	movb   $0x3,-0x2d(%ebp)
  101ae7:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
  101aeb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  101aee:	ee                   	out    %al,(%dx)
  101aef:	c7 45 dc fc 03 00 00 	movl   $0x3fc,-0x24(%ebp)
  101af6:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  101afa:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  101afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101b01:	ee                   	out    %al,(%dx)
  101b02:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
  101b09:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
  101b0d:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101b11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101b14:	ee                   	out    %al,(%dx)
  101b15:	c7 45 e8 fd 03 00 00 	movl   $0x3fd,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101b1f:	89 c2                	mov    %eax,%edx
  101b21:	ec                   	in     (%dx),%al
  101b22:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  101b25:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  101b29:	3c ff                	cmp    $0xff,%al
  101b2b:	0f 95 c0             	setne  %al
  101b2e:	0f b6 c0             	movzbl %al,%eax
  101b31:	a3 80 7f 10 00       	mov    %eax,0x107f80
  101b36:	c7 45 f0 fa 03 00 00 	movl   $0x3fa,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b40:	89 c2                	mov    %eax,%edx
  101b42:	ec                   	in     (%dx),%al
  101b43:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  101b46:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101b50:	89 c2                	mov    %eax,%edx
  101b52:	ec                   	in     (%dx),%al
  101b53:	88 45 ff             	mov    %al,-0x1(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);
}
  101b56:	c9                   	leave  
  101b57:	c3                   	ret    

00101b58 <nvram_read>:
#include <dev/nvram.h>


unsigned
nvram_read(unsigned reg)
{
  101b58:	55                   	push   %ebp
  101b59:	89 e5                	mov    %esp,%ebp
  101b5b:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b61:	0f b6 c0             	movzbl %al,%eax
  101b64:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  101b6b:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101b6e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101b72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101b75:	ee                   	out    %al,(%dx)
  101b76:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101b80:	89 c2                	mov    %eax,%edx
  101b82:	ec                   	in     (%dx),%al
  101b83:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  101b86:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(IO_RTC+1);
  101b8a:	0f b6 c0             	movzbl %al,%eax
}
  101b8d:	c9                   	leave  
  101b8e:	c3                   	ret    

00101b8f <nvram_read16>:

unsigned
nvram_read16(unsigned r)
{
  101b8f:	55                   	push   %ebp
  101b90:	89 e5                	mov    %esp,%ebp
  101b92:	53                   	push   %ebx
  101b93:	83 ec 04             	sub    $0x4,%esp
	return nvram_read(r) | (nvram_read(r + 1) << 8);
  101b96:	8b 45 08             	mov    0x8(%ebp),%eax
  101b99:	89 04 24             	mov    %eax,(%esp)
  101b9c:	e8 b7 ff ff ff       	call   101b58 <nvram_read>
  101ba1:	89 c3                	mov    %eax,%ebx
  101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba6:	83 c0 01             	add    $0x1,%eax
  101ba9:	89 04 24             	mov    %eax,(%esp)
  101bac:	e8 a7 ff ff ff       	call   101b58 <nvram_read>
  101bb1:	c1 e0 08             	shl    $0x8,%eax
  101bb4:	09 d8                	or     %ebx,%eax
}
  101bb6:	83 c4 04             	add    $0x4,%esp
  101bb9:	5b                   	pop    %ebx
  101bba:	5d                   	pop    %ebp
  101bbb:	c3                   	ret    

00101bbc <nvram_write>:

void
nvram_write(unsigned reg, unsigned datum)
{
  101bbc:	55                   	push   %ebp
  101bbd:	89 e5                	mov    %esp,%ebp
  101bbf:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc5:	0f b6 c0             	movzbl %al,%eax
  101bc8:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  101bcf:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101bd2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101bd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101bd9:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
  101bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  101bdd:	0f b6 c0             	movzbl %al,%eax
  101be0:	c7 45 fc 71 00 00 00 	movl   $0x71,-0x4(%ebp)
  101be7:	88 45 fb             	mov    %al,-0x5(%ebp)
  101bea:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101bee:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101bf1:	ee                   	out    %al,(%dx)
}
  101bf2:	c9                   	leave  
  101bf3:	c3                   	ret    

00101bf4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static uintmax_t
getuint(printstate *st, va_list *ap)
{
  101bf4:	55                   	push   %ebp
  101bf5:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfa:	8b 40 18             	mov    0x18(%eax),%eax
  101bfd:	83 e0 02             	and    $0x2,%eax
  101c00:	85 c0                	test   %eax,%eax
  101c02:	74 1c                	je     101c20 <getuint+0x2c>
		return va_arg(*ap, unsigned long long);
  101c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c07:	8b 00                	mov    (%eax),%eax
  101c09:	8d 50 08             	lea    0x8(%eax),%edx
  101c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c0f:	89 10                	mov    %edx,(%eax)
  101c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c14:	8b 00                	mov    (%eax),%eax
  101c16:	83 e8 08             	sub    $0x8,%eax
  101c19:	8b 50 04             	mov    0x4(%eax),%edx
  101c1c:	8b 00                	mov    (%eax),%eax
  101c1e:	eb 47                	jmp    101c67 <getuint+0x73>
	else if (st->flags & F_L)
  101c20:	8b 45 08             	mov    0x8(%ebp),%eax
  101c23:	8b 40 18             	mov    0x18(%eax),%eax
  101c26:	83 e0 01             	and    $0x1,%eax
  101c29:	84 c0                	test   %al,%al
  101c2b:	74 1e                	je     101c4b <getuint+0x57>
		return va_arg(*ap, unsigned long);
  101c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c30:	8b 00                	mov    (%eax),%eax
  101c32:	8d 50 04             	lea    0x4(%eax),%edx
  101c35:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c38:	89 10                	mov    %edx,(%eax)
  101c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c3d:	8b 00                	mov    (%eax),%eax
  101c3f:	83 e8 04             	sub    $0x4,%eax
  101c42:	8b 00                	mov    (%eax),%eax
  101c44:	ba 00 00 00 00       	mov    $0x0,%edx
  101c49:	eb 1c                	jmp    101c67 <getuint+0x73>
	else
		return va_arg(*ap, unsigned int);
  101c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c4e:	8b 00                	mov    (%eax),%eax
  101c50:	8d 50 04             	lea    0x4(%eax),%edx
  101c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c56:	89 10                	mov    %edx,(%eax)
  101c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c5b:	8b 00                	mov    (%eax),%eax
  101c5d:	83 e8 04             	sub    $0x4,%eax
  101c60:	8b 00                	mov    (%eax),%eax
  101c62:	ba 00 00 00 00       	mov    $0x0,%edx
}
  101c67:	5d                   	pop    %ebp
  101c68:	c3                   	ret    

00101c69 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static intmax_t
getint(printstate *st, va_list *ap)
{
  101c69:	55                   	push   %ebp
  101c6a:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6f:	8b 40 18             	mov    0x18(%eax),%eax
  101c72:	83 e0 02             	and    $0x2,%eax
  101c75:	85 c0                	test   %eax,%eax
  101c77:	74 1c                	je     101c95 <getint+0x2c>
		return va_arg(*ap, long long);
  101c79:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c7c:	8b 00                	mov    (%eax),%eax
  101c7e:	8d 50 08             	lea    0x8(%eax),%edx
  101c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c84:	89 10                	mov    %edx,(%eax)
  101c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c89:	8b 00                	mov    (%eax),%eax
  101c8b:	83 e8 08             	sub    $0x8,%eax
  101c8e:	8b 50 04             	mov    0x4(%eax),%edx
  101c91:	8b 00                	mov    (%eax),%eax
  101c93:	eb 47                	jmp    101cdc <getint+0x73>
	else if (st->flags & F_L)
  101c95:	8b 45 08             	mov    0x8(%ebp),%eax
  101c98:	8b 40 18             	mov    0x18(%eax),%eax
  101c9b:	83 e0 01             	and    $0x1,%eax
  101c9e:	84 c0                	test   %al,%al
  101ca0:	74 1e                	je     101cc0 <getint+0x57>
		return va_arg(*ap, long);
  101ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
  101ca5:	8b 00                	mov    (%eax),%eax
  101ca7:	8d 50 04             	lea    0x4(%eax),%edx
  101caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cad:	89 10                	mov    %edx,(%eax)
  101caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cb2:	8b 00                	mov    (%eax),%eax
  101cb4:	83 e8 04             	sub    $0x4,%eax
  101cb7:	8b 00                	mov    (%eax),%eax
  101cb9:	89 c2                	mov    %eax,%edx
  101cbb:	c1 fa 1f             	sar    $0x1f,%edx
  101cbe:	eb 1c                	jmp    101cdc <getint+0x73>
	else
		return va_arg(*ap, int);
  101cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cc3:	8b 00                	mov    (%eax),%eax
  101cc5:	8d 50 04             	lea    0x4(%eax),%edx
  101cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  101ccb:	89 10                	mov    %edx,(%eax)
  101ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cd0:	8b 00                	mov    (%eax),%eax
  101cd2:	83 e8 04             	sub    $0x4,%eax
  101cd5:	8b 00                	mov    (%eax),%eax
  101cd7:	89 c2                	mov    %eax,%edx
  101cd9:	c1 fa 1f             	sar    $0x1f,%edx
}
  101cdc:	5d                   	pop    %ebp
  101cdd:	c3                   	ret    

00101cde <putpad>:

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
  101cde:	55                   	push   %ebp
  101cdf:	89 e5                	mov    %esp,%ebp
  101ce1:	83 ec 18             	sub    $0x18,%esp
	while (--st->width >= 0)
  101ce4:	eb 1a                	jmp    101d00 <putpad+0x22>
		st->putch(st->padc, st->putdat);
  101ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce9:	8b 08                	mov    (%eax),%ecx
  101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  101cee:	8b 50 04             	mov    0x4(%eax),%edx
  101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf4:	8b 40 08             	mov    0x8(%eax),%eax
  101cf7:	89 54 24 04          	mov    %edx,0x4(%esp)
  101cfb:	89 04 24             	mov    %eax,(%esp)
  101cfe:	ff d1                	call   *%ecx

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
	while (--st->width >= 0)
  101d00:	8b 45 08             	mov    0x8(%ebp),%eax
  101d03:	8b 40 0c             	mov    0xc(%eax),%eax
  101d06:	8d 50 ff             	lea    -0x1(%eax),%edx
  101d09:	8b 45 08             	mov    0x8(%ebp),%eax
  101d0c:	89 50 0c             	mov    %edx,0xc(%eax)
  101d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d12:	8b 40 0c             	mov    0xc(%eax),%eax
  101d15:	85 c0                	test   %eax,%eax
  101d17:	79 cd                	jns    101ce6 <putpad+0x8>
		st->putch(st->padc, st->putdat);
}
  101d19:	c9                   	leave  
  101d1a:	c3                   	ret    

00101d1b <putstr>:

// Print a string with a specified maximum length (-1=unlimited),
// with any appropriate left or right field padding.
static void
putstr(printstate *st, const char *str, int maxlen)
{
  101d1b:	55                   	push   %ebp
  101d1c:	89 e5                	mov    %esp,%ebp
  101d1e:	53                   	push   %ebx
  101d1f:	83 ec 24             	sub    $0x24,%esp
	const char *lim;		// find where the string actually ends
	if (maxlen < 0)
  101d22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  101d26:	79 18                	jns    101d40 <putstr+0x25>
		lim = strchr(str, 0);	// find the terminating null
  101d28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101d2f:	00 
  101d30:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d33:	89 04 24             	mov    %eax,(%esp)
  101d36:	e8 e9 07 00 00       	call   102524 <strchr>
  101d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101d3e:	eb 2c                	jmp    101d6c <putstr+0x51>
	else if ((lim = memchr(str, 0, maxlen)) == NULL)
  101d40:	8b 45 10             	mov    0x10(%ebp),%eax
  101d43:	89 44 24 08          	mov    %eax,0x8(%esp)
  101d47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101d4e:	00 
  101d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d52:	89 04 24             	mov    %eax,(%esp)
  101d55:	e8 ce 09 00 00       	call   102728 <memchr>
  101d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101d5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  101d61:	75 09                	jne    101d6c <putstr+0x51>
		lim = str + maxlen;
  101d63:	8b 45 10             	mov    0x10(%ebp),%eax
  101d66:	03 45 0c             	add    0xc(%ebp),%eax
  101d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
	st->width -= (lim-str);		// deduct string length from field width
  101d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6f:	8b 40 0c             	mov    0xc(%eax),%eax
  101d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101d75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101d78:	89 cb                	mov    %ecx,%ebx
  101d7a:	29 d3                	sub    %edx,%ebx
  101d7c:	89 da                	mov    %ebx,%edx
  101d7e:	8d 14 10             	lea    (%eax,%edx,1),%edx
  101d81:	8b 45 08             	mov    0x8(%ebp),%eax
  101d84:	89 50 0c             	mov    %edx,0xc(%eax)

	if (!(st->flags & F_RPAD))	// print left-side padding
  101d87:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8a:	8b 40 18             	mov    0x18(%eax),%eax
  101d8d:	83 e0 10             	and    $0x10,%eax
  101d90:	85 c0                	test   %eax,%eax
  101d92:	75 32                	jne    101dc6 <putstr+0xab>
		putpad(st);		// (also leaves st->width == 0)
  101d94:	8b 45 08             	mov    0x8(%ebp),%eax
  101d97:	89 04 24             	mov    %eax,(%esp)
  101d9a:	e8 3f ff ff ff       	call   101cde <putpad>
	while (str < lim) {
  101d9f:	eb 25                	jmp    101dc6 <putstr+0xab>
		char ch = *str++;
  101da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  101da4:	0f b6 00             	movzbl (%eax),%eax
  101da7:	88 45 f7             	mov    %al,-0x9(%ebp)
  101daa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
			st->putch(ch, st->putdat);
  101dae:	8b 45 08             	mov    0x8(%ebp),%eax
  101db1:	8b 08                	mov    (%eax),%ecx
  101db3:	8b 45 08             	mov    0x8(%ebp),%eax
  101db6:	8b 50 04             	mov    0x4(%eax),%edx
  101db9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  101dc1:	89 04 24             	mov    %eax,(%esp)
  101dc4:	ff d1                	call   *%ecx
		lim = str + maxlen;
	st->width -= (lim-str);		// deduct string length from field width

	if (!(st->flags & F_RPAD))	// print left-side padding
		putpad(st);		// (also leaves st->width == 0)
	while (str < lim) {
  101dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  101dc9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  101dcc:	72 d3                	jb     101da1 <putstr+0x86>
		char ch = *str++;
			st->putch(ch, st->putdat);
	}
	putpad(st);			// print right-side padding
  101dce:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd1:	89 04 24             	mov    %eax,(%esp)
  101dd4:	e8 05 ff ff ff       	call   101cde <putpad>
}
  101dd9:	83 c4 24             	add    $0x24,%esp
  101ddc:	5b                   	pop    %ebx
  101ddd:	5d                   	pop    %ebp
  101dde:	c3                   	ret    

00101ddf <genint>:

// Generate a number (base <= 16) in reverse order into a string buffer.
static char *
genint(printstate *st, char *p, uintmax_t num)
{
  101ddf:	55                   	push   %ebp
  101de0:	89 e5                	mov    %esp,%ebp
  101de2:	53                   	push   %ebx
  101de3:	83 ec 24             	sub    $0x24,%esp
  101de6:	8b 45 10             	mov    0x10(%ebp),%eax
  101de9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101dec:	8b 45 14             	mov    0x14(%ebp),%eax
  101def:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= st->base)
  101df2:	8b 45 08             	mov    0x8(%ebp),%eax
  101df5:	8b 40 1c             	mov    0x1c(%eax),%eax
  101df8:	89 c2                	mov    %eax,%edx
  101dfa:	c1 fa 1f             	sar    $0x1f,%edx
  101dfd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  101e00:	77 4e                	ja     101e50 <genint+0x71>
  101e02:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  101e05:	72 05                	jb     101e0c <genint+0x2d>
  101e07:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  101e0a:	77 44                	ja     101e50 <genint+0x71>
		p = genint(st, p, num / st->base);	// output higher digits
  101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0f:	8b 40 1c             	mov    0x1c(%eax),%eax
  101e12:	89 c2                	mov    %eax,%edx
  101e14:	c1 fa 1f             	sar    $0x1f,%edx
  101e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  101e1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  101e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101e25:	89 04 24             	mov    %eax,(%esp)
  101e28:	89 54 24 04          	mov    %edx,0x4(%esp)
  101e2c:	e8 3f 09 00 00       	call   102770 <__udivdi3>
  101e31:	89 44 24 08          	mov    %eax,0x8(%esp)
  101e35:	89 54 24 0c          	mov    %edx,0xc(%esp)
  101e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  101e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e40:	8b 45 08             	mov    0x8(%ebp),%eax
  101e43:	89 04 24             	mov    %eax,(%esp)
  101e46:	e8 94 ff ff ff       	call   101ddf <genint>
  101e4b:	89 45 0c             	mov    %eax,0xc(%ebp)
  101e4e:	eb 1b                	jmp    101e6b <genint+0x8c>
	else if (st->signc >= 0)
  101e50:	8b 45 08             	mov    0x8(%ebp),%eax
  101e53:	8b 40 14             	mov    0x14(%eax),%eax
  101e56:	85 c0                	test   %eax,%eax
  101e58:	78 11                	js     101e6b <genint+0x8c>
		*p++ = st->signc;			// output leading sign
  101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5d:	8b 40 14             	mov    0x14(%eax),%eax
  101e60:	89 c2                	mov    %eax,%edx
  101e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  101e65:	88 10                	mov    %dl,(%eax)
  101e67:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	*p++ = "0123456789abcdef"[num % st->base];	// output this digit
  101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e6e:	8b 40 1c             	mov    0x1c(%eax),%eax
  101e71:	89 c1                	mov    %eax,%ecx
  101e73:	89 c3                	mov    %eax,%ebx
  101e75:	c1 fb 1f             	sar    $0x1f,%ebx
  101e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101e7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101e7e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  101e82:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  101e86:	89 04 24             	mov    %eax,(%esp)
  101e89:	89 54 24 04          	mov    %edx,0x4(%esp)
  101e8d:	e8 0e 0a 00 00       	call   1028a0 <__umoddi3>
  101e92:	05 3c 33 10 00       	add    $0x10333c,%eax
  101e97:	0f b6 10             	movzbl (%eax),%edx
  101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  101e9d:	88 10                	mov    %dl,(%eax)
  101e9f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return p;
  101ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
}
  101ea6:	83 c4 24             	add    $0x24,%esp
  101ea9:	5b                   	pop    %ebx
  101eaa:	5d                   	pop    %ebp
  101eab:	c3                   	ret    

00101eac <putint>:

// Print an integer with any appropriate field padding.
static void
putint(printstate *st, uintmax_t num, int base)
{
  101eac:	55                   	push   %ebp
  101ead:	89 e5                	mov    %esp,%ebp
  101eaf:	83 ec 58             	sub    $0x58,%esp
  101eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  101eb5:	89 45 c0             	mov    %eax,-0x40(%ebp)
  101eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  101ebb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	char buf[30], *p = buf;		// big enough for any 64-bit int in octal
  101ebe:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  101ec1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	st->base = base;		// select base for genint
  101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec7:	8b 55 14             	mov    0x14(%ebp),%edx
  101eca:	89 50 1c             	mov    %edx,0x1c(%eax)
	p = genint(st, p, num);		// output to the string buffer
  101ecd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  101ed0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  101ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
  101ed7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  101edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee5:	89 04 24             	mov    %eax,(%esp)
  101ee8:	e8 f2 fe ff ff       	call   101ddf <genint>
  101eed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	putstr(st, buf, p-buf);		// print it with left/right padding
  101ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101ef3:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  101ef6:	89 d1                	mov    %edx,%ecx
  101ef8:	29 c1                	sub    %eax,%ecx
  101efa:	89 c8                	mov    %ecx,%eax
  101efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  101f00:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  101f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f07:	8b 45 08             	mov    0x8(%ebp),%eax
  101f0a:	89 04 24             	mov    %eax,(%esp)
  101f0d:	e8 09 fe ff ff       	call   101d1b <putstr>
}
  101f12:	c9                   	leave  
  101f13:	c3                   	ret    

00101f14 <vprintfmt>:
#endif	// ! PIOS_KERNEL

// Main function to format and print a string.
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  101f14:	55                   	push   %ebp
  101f15:	89 e5                	mov    %esp,%ebp
  101f17:	53                   	push   %ebx
  101f18:	83 ec 44             	sub    $0x44,%esp
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
  101f1b:	8d 55 c8             	lea    -0x38(%ebp),%edx
  101f1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  101f23:	b8 20 00 00 00       	mov    $0x20,%eax
  101f28:	89 c3                	mov    %eax,%ebx
  101f2a:	83 e3 fc             	and    $0xfffffffc,%ebx
  101f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  101f32:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
  101f35:	83 c0 04             	add    $0x4,%eax
  101f38:	39 d8                	cmp    %ebx,%eax
  101f3a:	72 f6                	jb     101f32 <vprintfmt+0x1e>
  101f3c:	01 c2                	add    %eax,%edx
  101f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f41:	89 45 c8             	mov    %eax,-0x38(%ebp)
  101f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  101f47:	89 45 cc             	mov    %eax,-0x34(%ebp)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  101f4a:	eb 17                	jmp    101f63 <vprintfmt+0x4f>
			if (ch == '\0')
  101f4c:	85 db                	test   %ebx,%ebx
  101f4e:	0f 84 52 03 00 00    	je     1022a6 <vprintfmt+0x392>
				return;
			putch(ch, putdat);
  101f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  101f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f5b:	89 1c 24             	mov    %ebx,(%esp)
  101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f61:	ff d0                	call   *%eax
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  101f63:	8b 45 10             	mov    0x10(%ebp),%eax
  101f66:	0f b6 00             	movzbl (%eax),%eax
  101f69:	0f b6 d8             	movzbl %al,%ebx
  101f6c:	83 fb 25             	cmp    $0x25,%ebx
  101f6f:	0f 95 c0             	setne  %al
  101f72:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  101f76:	84 c0                	test   %al,%al
  101f78:	75 d2                	jne    101f4c <vprintfmt+0x38>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		st.padc = ' ';
  101f7a:	c7 45 d0 20 00 00 00 	movl   $0x20,-0x30(%ebp)
		st.width = -1;
  101f81:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		st.prec = -1;
  101f88:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		st.signc = -1;
  101f8f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		st.flags = 0;
  101f96:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		st.base = 10;
  101f9d:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
  101fa4:	eb 04                	jmp    101faa <vprintfmt+0x96>
			goto reswitch;

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
				st.signc = ' ';
			goto reswitch;
  101fa6:	90                   	nop
  101fa7:	eb 01                	jmp    101faa <vprintfmt+0x96>
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
				st.width = st.prec;	// then it's a field width
				st.prec = -1;
			}
			goto reswitch;
  101fa9:	90                   	nop
		st.signc = -1;
		st.flags = 0;
		st.base = 10;
		uintmax_t num;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  101faa:	8b 45 10             	mov    0x10(%ebp),%eax
  101fad:	0f b6 00             	movzbl (%eax),%eax
  101fb0:	0f b6 d8             	movzbl %al,%ebx
  101fb3:	89 d8                	mov    %ebx,%eax
  101fb5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  101fb9:	83 e8 20             	sub    $0x20,%eax
  101fbc:	83 f8 58             	cmp    $0x58,%eax
  101fbf:	0f 87 b1 02 00 00    	ja     102276 <vprintfmt+0x362>
  101fc5:	8b 04 85 54 33 10 00 	mov    0x103354(,%eax,4),%eax
  101fcc:	ff e0                	jmp    *%eax

		// modifier flags
		case '-': // pad on the right instead of the left
			st.flags |= F_RPAD;
  101fce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101fd1:	83 c8 10             	or     $0x10,%eax
  101fd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  101fd7:	eb d1                	jmp    101faa <vprintfmt+0x96>

		case '+': // prefix positive numeric values with a '+' sign
			st.signc = '+';
  101fd9:	c7 45 dc 2b 00 00 00 	movl   $0x2b,-0x24(%ebp)
			goto reswitch;
  101fe0:	eb c8                	jmp    101faa <vprintfmt+0x96>

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
  101fe2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101fe5:	85 c0                	test   %eax,%eax
  101fe7:	79 bd                	jns    101fa6 <vprintfmt+0x92>
				st.signc = ' ';
  101fe9:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
			goto reswitch;
  101ff0:	eb b8                	jmp    101faa <vprintfmt+0x96>

		// width or precision field
		case '0':
			if (!(st.flags & F_DOT))
  101ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101ff5:	83 e0 08             	and    $0x8,%eax
  101ff8:	85 c0                	test   %eax,%eax
  101ffa:	75 07                	jne    102003 <vprintfmt+0xef>
				st.padc = '0'; // pad with 0's instead of spaces
  101ffc:	c7 45 d0 30 00 00 00 	movl   $0x30,-0x30(%ebp)
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  102003:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
				st.prec = st.prec * 10 + ch - '0';
  10200a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10200d:	89 d0                	mov    %edx,%eax
  10200f:	c1 e0 02             	shl    $0x2,%eax
  102012:	01 d0                	add    %edx,%eax
  102014:	01 c0                	add    %eax,%eax
  102016:	01 d8                	add    %ebx,%eax
  102018:	83 e8 30             	sub    $0x30,%eax
  10201b:	89 45 d8             	mov    %eax,-0x28(%ebp)
				ch = *fmt;
  10201e:	8b 45 10             	mov    0x10(%ebp),%eax
  102021:	0f b6 00             	movzbl (%eax),%eax
  102024:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  102027:	83 fb 2f             	cmp    $0x2f,%ebx
  10202a:	7e 21                	jle    10204d <vprintfmt+0x139>
  10202c:	83 fb 39             	cmp    $0x39,%ebx
  10202f:	7f 1f                	jg     102050 <vprintfmt+0x13c>
		case '0':
			if (!(st.flags & F_DOT))
				st.padc = '0'; // pad with 0's instead of spaces
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  102031:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  102035:	eb d3                	jmp    10200a <vprintfmt+0xf6>
			goto gotprec;

		case '*':
			st.prec = va_arg(ap, int);
  102037:	8b 45 14             	mov    0x14(%ebp),%eax
  10203a:	83 c0 04             	add    $0x4,%eax
  10203d:	89 45 14             	mov    %eax,0x14(%ebp)
  102040:	8b 45 14             	mov    0x14(%ebp),%eax
  102043:	83 e8 04             	sub    $0x4,%eax
  102046:	8b 00                	mov    (%eax),%eax
  102048:	89 45 d8             	mov    %eax,-0x28(%ebp)
  10204b:	eb 04                	jmp    102051 <vprintfmt+0x13d>
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto gotprec;
  10204d:	90                   	nop
  10204e:	eb 01                	jmp    102051 <vprintfmt+0x13d>
  102050:	90                   	nop

		case '*':
			st.prec = va_arg(ap, int);
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
  102051:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102054:	83 e0 08             	and    $0x8,%eax
  102057:	85 c0                	test   %eax,%eax
  102059:	0f 85 4a ff ff ff    	jne    101fa9 <vprintfmt+0x95>
				st.width = st.prec;	// then it's a field width
  10205f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102062:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				st.prec = -1;
  102065:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
			}
			goto reswitch;
  10206c:	e9 39 ff ff ff       	jmp    101faa <vprintfmt+0x96>

		case '.':
			st.flags |= F_DOT;
  102071:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102074:	83 c8 08             	or     $0x8,%eax
  102077:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  10207a:	e9 2b ff ff ff       	jmp    101faa <vprintfmt+0x96>

		case '#':
			st.flags |= F_ALT;
  10207f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102082:	83 c8 04             	or     $0x4,%eax
  102085:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  102088:	e9 1d ff ff ff       	jmp    101faa <vprintfmt+0x96>

		// long flag (doubled for long long)
		case 'l':
			st.flags |= (st.flags & F_L) ? F_LL : F_L;
  10208d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102090:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102093:	83 e0 01             	and    $0x1,%eax
  102096:	84 c0                	test   %al,%al
  102098:	74 07                	je     1020a1 <vprintfmt+0x18d>
  10209a:	b8 02 00 00 00       	mov    $0x2,%eax
  10209f:	eb 05                	jmp    1020a6 <vprintfmt+0x192>
  1020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  1020a6:	09 d0                	or     %edx,%eax
  1020a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  1020ab:	e9 fa fe ff ff       	jmp    101faa <vprintfmt+0x96>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  1020b0:	8b 45 14             	mov    0x14(%ebp),%eax
  1020b3:	83 c0 04             	add    $0x4,%eax
  1020b6:	89 45 14             	mov    %eax,0x14(%ebp)
  1020b9:	8b 45 14             	mov    0x14(%ebp),%eax
  1020bc:	83 e8 04             	sub    $0x4,%eax
  1020bf:	8b 00                	mov    (%eax),%eax
  1020c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  1020c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1020c8:	89 04 24             	mov    %eax,(%esp)
  1020cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1020ce:	ff d0                	call   *%eax
			break;
  1020d0:	e9 cb 01 00 00       	jmp    1022a0 <vprintfmt+0x38c>

		// string
		case 's': {
			const char *s;
			if ((s = va_arg(ap, char *)) == NULL)
  1020d5:	8b 45 14             	mov    0x14(%ebp),%eax
  1020d8:	83 c0 04             	add    $0x4,%eax
  1020db:	89 45 14             	mov    %eax,0x14(%ebp)
  1020de:	8b 45 14             	mov    0x14(%ebp),%eax
  1020e1:	83 e8 04             	sub    $0x4,%eax
  1020e4:	8b 00                	mov    (%eax),%eax
  1020e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1020e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1020ed:	75 07                	jne    1020f6 <vprintfmt+0x1e2>
				s = "(null)";
  1020ef:	c7 45 f4 4d 33 10 00 	movl   $0x10334d,-0xc(%ebp)
			putstr(&st, s, st.prec);
  1020f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1020f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1020fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102100:	89 44 24 04          	mov    %eax,0x4(%esp)
  102104:	8d 45 c8             	lea    -0x38(%ebp),%eax
  102107:	89 04 24             	mov    %eax,(%esp)
  10210a:	e8 0c fc ff ff       	call   101d1b <putstr>
			break;
  10210f:	e9 8c 01 00 00       	jmp    1022a0 <vprintfmt+0x38c>
		    }

		// (signed) decimal
		case 'd':
			num = getint(&st, &ap);
  102114:	8d 45 14             	lea    0x14(%ebp),%eax
  102117:	89 44 24 04          	mov    %eax,0x4(%esp)
  10211b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10211e:	89 04 24             	mov    %eax,(%esp)
  102121:	e8 43 fb ff ff       	call   101c69 <getint>
  102126:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102129:	89 55 ec             	mov    %edx,-0x14(%ebp)
			if ((intmax_t) num < 0) {
  10212c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10212f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102132:	85 d2                	test   %edx,%edx
  102134:	79 1a                	jns    102150 <vprintfmt+0x23c>
				num = -(intmax_t) num;
  102136:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102139:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10213c:	f7 d8                	neg    %eax
  10213e:	83 d2 00             	adc    $0x0,%edx
  102141:	f7 da                	neg    %edx
  102143:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102146:	89 55 ec             	mov    %edx,-0x14(%ebp)
				st.signc = '-';
  102149:	c7 45 dc 2d 00 00 00 	movl   $0x2d,-0x24(%ebp)
			}
			putint(&st, num, 10);
  102150:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  102157:	00 
  102158:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10215b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10215e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102162:	89 54 24 08          	mov    %edx,0x8(%esp)
  102166:	8d 45 c8             	lea    -0x38(%ebp),%eax
  102169:	89 04 24             	mov    %eax,(%esp)
  10216c:	e8 3b fd ff ff       	call   101eac <putint>
			break;
  102171:	e9 2a 01 00 00       	jmp    1022a0 <vprintfmt+0x38c>

		// unsigned decimal
		case 'u':
			putint(&st, getuint(&st, &ap), 10);
  102176:	8d 45 14             	lea    0x14(%ebp),%eax
  102179:	89 44 24 04          	mov    %eax,0x4(%esp)
  10217d:	8d 45 c8             	lea    -0x38(%ebp),%eax
  102180:	89 04 24             	mov    %eax,(%esp)
  102183:	e8 6c fa ff ff       	call   101bf4 <getuint>
  102188:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  10218f:	00 
  102190:	89 44 24 04          	mov    %eax,0x4(%esp)
  102194:	89 54 24 08          	mov    %edx,0x8(%esp)
  102198:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10219b:	89 04 24             	mov    %eax,(%esp)
  10219e:	e8 09 fd ff ff       	call   101eac <putint>
			break;
  1021a3:	e9 f8 00 00 00       	jmp    1022a0 <vprintfmt+0x38c>

		// (unsigned) octal
		case 'o':
			putint(&st, getuint(&st, &ap), 8);
  1021a8:	8d 45 14             	lea    0x14(%ebp),%eax
  1021ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021af:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021b2:	89 04 24             	mov    %eax,(%esp)
  1021b5:	e8 3a fa ff ff       	call   101bf4 <getuint>
  1021ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  1021c1:	00 
  1021c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1021ca:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021cd:	89 04 24             	mov    %eax,(%esp)
  1021d0:	e8 d7 fc ff ff       	call   101eac <putint>
			// Replace this with your code.
			/*putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);*/
			break;
  1021d5:	e9 c6 00 00 00       	jmp    1022a0 <vprintfmt+0x38c>

		// (unsigned) hexadecimal
		case 'x':
			putint(&st, getuint(&st, &ap), 16);
  1021da:	8d 45 14             	lea    0x14(%ebp),%eax
  1021dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021e1:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021e4:	89 04 24             	mov    %eax,(%esp)
  1021e7:	e8 08 fa ff ff       	call   101bf4 <getuint>
  1021ec:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  1021f3:	00 
  1021f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021f8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1021fc:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021ff:	89 04 24             	mov    %eax,(%esp)
  102202:	e8 a5 fc ff ff       	call   101eac <putint>
			break;
  102207:	e9 94 00 00 00       	jmp    1022a0 <vprintfmt+0x38c>

		// pointer
		case 'p':
			putch('0', putdat);
  10220c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10220f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102213:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  10221a:	8b 45 08             	mov    0x8(%ebp),%eax
  10221d:	ff d0                	call   *%eax
			putch('x', putdat);
  10221f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102222:	89 44 24 04          	mov    %eax,0x4(%esp)
  102226:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10222d:	8b 45 08             	mov    0x8(%ebp),%eax
  102230:	ff d0                	call   *%eax
			putint(&st, (uintptr_t) va_arg(ap, void *), 16);
  102232:	8b 45 14             	mov    0x14(%ebp),%eax
  102235:	83 c0 04             	add    $0x4,%eax
  102238:	89 45 14             	mov    %eax,0x14(%ebp)
  10223b:	8b 45 14             	mov    0x14(%ebp),%eax
  10223e:	83 e8 04             	sub    $0x4,%eax
  102241:	8b 00                	mov    (%eax),%eax
  102243:	ba 00 00 00 00       	mov    $0x0,%edx
  102248:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  10224f:	00 
  102250:	89 44 24 04          	mov    %eax,0x4(%esp)
  102254:	89 54 24 08          	mov    %edx,0x8(%esp)
  102258:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10225b:	89 04 24             	mov    %eax,(%esp)
  10225e:	e8 49 fc ff ff       	call   101eac <putint>
			break;
  102263:	eb 3b                	jmp    1022a0 <vprintfmt+0x38c>
		    }
#endif	// ! PIOS_KERNEL

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  102265:	8b 45 0c             	mov    0xc(%ebp),%eax
  102268:	89 44 24 04          	mov    %eax,0x4(%esp)
  10226c:	89 1c 24             	mov    %ebx,(%esp)
  10226f:	8b 45 08             	mov    0x8(%ebp),%eax
  102272:	ff d0                	call   *%eax
			break;
  102274:	eb 2a                	jmp    1022a0 <vprintfmt+0x38c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  102276:	8b 45 0c             	mov    0xc(%ebp),%eax
  102279:	89 44 24 04          	mov    %eax,0x4(%esp)
  10227d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  102284:	8b 45 08             	mov    0x8(%ebp),%eax
  102287:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  102289:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10228d:	eb 04                	jmp    102293 <vprintfmt+0x37f>
  10228f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102293:	8b 45 10             	mov    0x10(%ebp),%eax
  102296:	83 e8 01             	sub    $0x1,%eax
  102299:	0f b6 00             	movzbl (%eax),%eax
  10229c:	3c 25                	cmp    $0x25,%al
  10229e:	75 ef                	jne    10228f <vprintfmt+0x37b>
				/* do nothing */;
			break;
		}
	}
  1022a0:	90                   	nop
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  1022a1:	e9 bd fc ff ff       	jmp    101f63 <vprintfmt+0x4f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  1022a6:	83 c4 44             	add    $0x44,%esp
  1022a9:	5b                   	pop    %ebx
  1022aa:	5d                   	pop    %ebp
  1022ab:	c3                   	ret    

001022ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  1022ac:	55                   	push   %ebp
  1022ad:	89 e5                	mov    %esp,%ebp
  1022af:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  1022b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022b5:	8b 00                	mov    (%eax),%eax
  1022b7:	8b 55 08             	mov    0x8(%ebp),%edx
  1022ba:	89 d1                	mov    %edx,%ecx
  1022bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1022bf:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
  1022c3:	8d 50 01             	lea    0x1(%eax),%edx
  1022c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022c9:	89 10                	mov    %edx,(%eax)
	if (b->idx == CPUTS_MAX-1) {
  1022cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022ce:	8b 00                	mov    (%eax),%eax
  1022d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  1022d5:	75 24                	jne    1022fb <putch+0x4f>
		b->buf[b->idx] = 0;
  1022d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022da:	8b 00                	mov    (%eax),%eax
  1022dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1022df:	c6 44 02 08 00       	movb   $0x0,0x8(%edx,%eax,1)
		cputs(b->buf);
  1022e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022e7:	83 c0 08             	add    $0x8,%eax
  1022ea:	89 04 24             	mov    %eax,(%esp)
  1022ed:	e8 13 e0 ff ff       	call   100305 <cputs>
		b->idx = 0;
  1022f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  1022fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022fe:	8b 40 04             	mov    0x4(%eax),%eax
  102301:	8d 50 01             	lea    0x1(%eax),%edx
  102304:	8b 45 0c             	mov    0xc(%ebp),%eax
  102307:	89 50 04             	mov    %edx,0x4(%eax)
}
  10230a:	c9                   	leave  
  10230b:	c3                   	ret    

0010230c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  10230c:	55                   	push   %ebp
  10230d:	89 e5                	mov    %esp,%ebp
  10230f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  102315:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  10231c:	00 00 00 
	b.cnt = 0;
  10231f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  102326:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  102329:	b8 ac 22 10 00       	mov    $0x1022ac,%eax
  10232e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102331:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102335:	8b 55 08             	mov    0x8(%ebp),%edx
  102338:	89 54 24 08          	mov    %edx,0x8(%esp)
  10233c:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  102342:	89 54 24 04          	mov    %edx,0x4(%esp)
  102346:	89 04 24             	mov    %eax,(%esp)
  102349:	e8 c6 fb ff ff       	call   101f14 <vprintfmt>

	b.buf[b.idx] = 0;
  10234e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  102354:	c6 84 05 f8 fe ff ff 	movb   $0x0,-0x108(%ebp,%eax,1)
  10235b:	00 
	cputs(b.buf);
  10235c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  102362:	83 c0 08             	add    $0x8,%eax
  102365:	89 04 24             	mov    %eax,(%esp)
  102368:	e8 98 df ff ff       	call   100305 <cputs>

	return b.cnt;
  10236d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  102373:	c9                   	leave  
  102374:	c3                   	ret    

00102375 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  102375:	55                   	push   %ebp
  102376:	89 e5                	mov    %esp,%ebp
  102378:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  10237b:	8d 45 08             	lea    0x8(%ebp),%eax
  10237e:	83 c0 04             	add    $0x4,%eax
  102381:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  102384:	8b 45 08             	mov    0x8(%ebp),%eax
  102387:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10238a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10238e:	89 04 24             	mov    %eax,(%esp)
  102391:	e8 76 ff ff ff       	call   10230c <vcprintf>
  102396:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  102399:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10239c:	c9                   	leave  
  10239d:	c3                   	ret    
  10239e:	90                   	nop
  10239f:	90                   	nop

001023a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  1023a0:	55                   	push   %ebp
  1023a1:	89 e5                	mov    %esp,%ebp
  1023a3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  1023a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1023ad:	eb 08                	jmp    1023b7 <strlen+0x17>
		n++;
  1023af:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  1023b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1023b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1023ba:	0f b6 00             	movzbl (%eax),%eax
  1023bd:	84 c0                	test   %al,%al
  1023bf:	75 ee                	jne    1023af <strlen+0xf>
		n++;
	return n;
  1023c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1023c4:	c9                   	leave  
  1023c5:	c3                   	ret    

001023c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  1023c6:	55                   	push   %ebp
  1023c7:	89 e5                	mov    %esp,%ebp
  1023c9:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  1023cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1023cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  1023d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1023d5:	0f b6 10             	movzbl (%eax),%edx
  1023d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1023db:	88 10                	mov    %dl,(%eax)
  1023dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1023e0:	0f b6 00             	movzbl (%eax),%eax
  1023e3:	84 c0                	test   %al,%al
  1023e5:	0f 95 c0             	setne  %al
  1023e8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1023ec:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  1023f0:	84 c0                	test   %al,%al
  1023f2:	75 de                	jne    1023d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
  1023f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1023f7:	c9                   	leave  
  1023f8:	c3                   	ret    

001023f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  1023f9:	55                   	push   %ebp
  1023fa:	89 e5                	mov    %esp,%ebp
  1023fc:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  1023ff:	8b 45 08             	mov    0x8(%ebp),%eax
  102402:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < size; i++) {
  102405:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  10240c:	eb 21                	jmp    10242f <strncpy+0x36>
		*dst++ = *src;
  10240e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102411:	0f b6 10             	movzbl (%eax),%edx
  102414:	8b 45 08             	mov    0x8(%ebp),%eax
  102417:	88 10                	mov    %dl,(%eax)
  102419:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  10241d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102420:	0f b6 00             	movzbl (%eax),%eax
  102423:	84 c0                	test   %al,%al
  102425:	74 04                	je     10242b <strncpy+0x32>
			src++;
  102427:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  10242b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  10242f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102432:	3b 45 10             	cmp    0x10(%ebp),%eax
  102435:	72 d7                	jb     10240e <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  102437:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10243a:	c9                   	leave  
  10243b:	c3                   	ret    

0010243c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  10243c:	55                   	push   %ebp
  10243d:	89 e5                	mov    %esp,%ebp
  10243f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  102442:	8b 45 08             	mov    0x8(%ebp),%eax
  102445:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  102448:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10244c:	74 2f                	je     10247d <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
  10244e:	eb 13                	jmp    102463 <strlcpy+0x27>
			*dst++ = *src++;
  102450:	8b 45 0c             	mov    0xc(%ebp),%eax
  102453:	0f b6 10             	movzbl (%eax),%edx
  102456:	8b 45 08             	mov    0x8(%ebp),%eax
  102459:	88 10                	mov    %dl,(%eax)
  10245b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10245f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  102463:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102467:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10246b:	74 0a                	je     102477 <strlcpy+0x3b>
  10246d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102470:	0f b6 00             	movzbl (%eax),%eax
  102473:	84 c0                	test   %al,%al
  102475:	75 d9                	jne    102450 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  102477:	8b 45 08             	mov    0x8(%ebp),%eax
  10247a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  10247d:	8b 55 08             	mov    0x8(%ebp),%edx
  102480:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102483:	89 d1                	mov    %edx,%ecx
  102485:	29 c1                	sub    %eax,%ecx
  102487:	89 c8                	mov    %ecx,%eax
}
  102489:	c9                   	leave  
  10248a:	c3                   	ret    

0010248b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  10248b:	55                   	push   %ebp
  10248c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  10248e:	eb 08                	jmp    102498 <strcmp+0xd>
		p++, q++;
  102490:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102494:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  102498:	8b 45 08             	mov    0x8(%ebp),%eax
  10249b:	0f b6 00             	movzbl (%eax),%eax
  10249e:	84 c0                	test   %al,%al
  1024a0:	74 10                	je     1024b2 <strcmp+0x27>
  1024a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1024a5:	0f b6 10             	movzbl (%eax),%edx
  1024a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1024ab:	0f b6 00             	movzbl (%eax),%eax
  1024ae:	38 c2                	cmp    %al,%dl
  1024b0:	74 de                	je     102490 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  1024b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1024b5:	0f b6 00             	movzbl (%eax),%eax
  1024b8:	0f b6 d0             	movzbl %al,%edx
  1024bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1024be:	0f b6 00             	movzbl (%eax),%eax
  1024c1:	0f b6 c0             	movzbl %al,%eax
  1024c4:	89 d1                	mov    %edx,%ecx
  1024c6:	29 c1                	sub    %eax,%ecx
  1024c8:	89 c8                	mov    %ecx,%eax
}
  1024ca:	5d                   	pop    %ebp
  1024cb:	c3                   	ret    

001024cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  1024cc:	55                   	push   %ebp
  1024cd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  1024cf:	eb 0c                	jmp    1024dd <strncmp+0x11>
		n--, p++, q++;
  1024d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1024d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1024d9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  1024dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1024e1:	74 1a                	je     1024fd <strncmp+0x31>
  1024e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1024e6:	0f b6 00             	movzbl (%eax),%eax
  1024e9:	84 c0                	test   %al,%al
  1024eb:	74 10                	je     1024fd <strncmp+0x31>
  1024ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1024f0:	0f b6 10             	movzbl (%eax),%edx
  1024f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1024f6:	0f b6 00             	movzbl (%eax),%eax
  1024f9:	38 c2                	cmp    %al,%dl
  1024fb:	74 d4                	je     1024d1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  1024fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102501:	75 07                	jne    10250a <strncmp+0x3e>
		return 0;
  102503:	b8 00 00 00 00       	mov    $0x0,%eax
  102508:	eb 18                	jmp    102522 <strncmp+0x56>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  10250a:	8b 45 08             	mov    0x8(%ebp),%eax
  10250d:	0f b6 00             	movzbl (%eax),%eax
  102510:	0f b6 d0             	movzbl %al,%edx
  102513:	8b 45 0c             	mov    0xc(%ebp),%eax
  102516:	0f b6 00             	movzbl (%eax),%eax
  102519:	0f b6 c0             	movzbl %al,%eax
  10251c:	89 d1                	mov    %edx,%ecx
  10251e:	29 c1                	sub    %eax,%ecx
  102520:	89 c8                	mov    %ecx,%eax
}
  102522:	5d                   	pop    %ebp
  102523:	c3                   	ret    

00102524 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  102524:	55                   	push   %ebp
  102525:	89 e5                	mov    %esp,%ebp
  102527:	83 ec 04             	sub    $0x4,%esp
  10252a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10252d:	88 45 fc             	mov    %al,-0x4(%ebp)
	while (*s != c)
  102530:	eb 1a                	jmp    10254c <strchr+0x28>
		if (*s++ == 0)
  102532:	8b 45 08             	mov    0x8(%ebp),%eax
  102535:	0f b6 00             	movzbl (%eax),%eax
  102538:	84 c0                	test   %al,%al
  10253a:	0f 94 c0             	sete   %al
  10253d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102541:	84 c0                	test   %al,%al
  102543:	74 07                	je     10254c <strchr+0x28>
			return NULL;
  102545:	b8 00 00 00 00       	mov    $0x0,%eax
  10254a:	eb 0e                	jmp    10255a <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	while (*s != c)
  10254c:	8b 45 08             	mov    0x8(%ebp),%eax
  10254f:	0f b6 00             	movzbl (%eax),%eax
  102552:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102555:	75 db                	jne    102532 <strchr+0xe>
		if (*s++ == 0)
			return NULL;
	return (char *) s;
  102557:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10255a:	c9                   	leave  
  10255b:	c3                   	ret    

0010255c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  10255c:	55                   	push   %ebp
  10255d:	89 e5                	mov    %esp,%ebp
  10255f:	57                   	push   %edi
  102560:	83 ec 10             	sub    $0x10,%esp
	char *p;

	if (n == 0)
  102563:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102567:	75 05                	jne    10256e <memset+0x12>
		return v;
  102569:	8b 45 08             	mov    0x8(%ebp),%eax
  10256c:	eb 5c                	jmp    1025ca <memset+0x6e>
	if ((int)v%4 == 0 && n%4 == 0) {
  10256e:	8b 45 08             	mov    0x8(%ebp),%eax
  102571:	83 e0 03             	and    $0x3,%eax
  102574:	85 c0                	test   %eax,%eax
  102576:	75 41                	jne    1025b9 <memset+0x5d>
  102578:	8b 45 10             	mov    0x10(%ebp),%eax
  10257b:	83 e0 03             	and    $0x3,%eax
  10257e:	85 c0                	test   %eax,%eax
  102580:	75 37                	jne    1025b9 <memset+0x5d>
		c &= 0xFF;
  102582:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  102589:	8b 45 0c             	mov    0xc(%ebp),%eax
  10258c:	89 c2                	mov    %eax,%edx
  10258e:	c1 e2 18             	shl    $0x18,%edx
  102591:	8b 45 0c             	mov    0xc(%ebp),%eax
  102594:	c1 e0 10             	shl    $0x10,%eax
  102597:	09 c2                	or     %eax,%edx
  102599:	8b 45 0c             	mov    0xc(%ebp),%eax
  10259c:	c1 e0 08             	shl    $0x8,%eax
  10259f:	09 d0                	or     %edx,%eax
  1025a1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  1025a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1025a7:	89 c1                	mov    %eax,%ecx
  1025a9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  1025ac:	8b 55 08             	mov    0x8(%ebp),%edx
  1025af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025b2:	89 d7                	mov    %edx,%edi
  1025b4:	fc                   	cld    
  1025b5:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  1025b7:	eb 0e                	jmp    1025c7 <memset+0x6b>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  1025b9:	8b 55 08             	mov    0x8(%ebp),%edx
  1025bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  1025c2:	89 d7                	mov    %edx,%edi
  1025c4:	fc                   	cld    
  1025c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  1025c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1025ca:	83 c4 10             	add    $0x10,%esp
  1025cd:	5f                   	pop    %edi
  1025ce:	5d                   	pop    %ebp
  1025cf:	c3                   	ret    

001025d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  1025d0:	55                   	push   %ebp
  1025d1:	89 e5                	mov    %esp,%ebp
  1025d3:	57                   	push   %edi
  1025d4:	56                   	push   %esi
  1025d5:	53                   	push   %ebx
  1025d6:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  1025d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	d = dst;
  1025df:	8b 45 08             	mov    0x8(%ebp),%eax
  1025e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (s < d && s + n > d) {
  1025e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1025e8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1025eb:	73 6e                	jae    10265b <memmove+0x8b>
  1025ed:	8b 45 10             	mov    0x10(%ebp),%eax
  1025f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1025f3:	8d 04 02             	lea    (%edx,%eax,1),%eax
  1025f6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1025f9:	76 60                	jbe    10265b <memmove+0x8b>
		s += n;
  1025fb:	8b 45 10             	mov    0x10(%ebp),%eax
  1025fe:	01 45 ec             	add    %eax,-0x14(%ebp)
		d += n;
  102601:	8b 45 10             	mov    0x10(%ebp),%eax
  102604:	01 45 f0             	add    %eax,-0x10(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  102607:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10260a:	83 e0 03             	and    $0x3,%eax
  10260d:	85 c0                	test   %eax,%eax
  10260f:	75 2f                	jne    102640 <memmove+0x70>
  102611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102614:	83 e0 03             	and    $0x3,%eax
  102617:	85 c0                	test   %eax,%eax
  102619:	75 25                	jne    102640 <memmove+0x70>
  10261b:	8b 45 10             	mov    0x10(%ebp),%eax
  10261e:	83 e0 03             	and    $0x3,%eax
  102621:	85 c0                	test   %eax,%eax
  102623:	75 1b                	jne    102640 <memmove+0x70>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  102625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102628:	83 e8 04             	sub    $0x4,%eax
  10262b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10262e:	83 ea 04             	sub    $0x4,%edx
  102631:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102634:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  102637:	89 c7                	mov    %eax,%edi
  102639:	89 d6                	mov    %edx,%esi
  10263b:	fd                   	std    
  10263c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10263e:	eb 18                	jmp    102658 <memmove+0x88>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  102640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102643:	8d 50 ff             	lea    -0x1(%eax),%edx
  102646:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102649:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  10264c:	8b 45 10             	mov    0x10(%ebp),%eax
  10264f:	89 d7                	mov    %edx,%edi
  102651:	89 de                	mov    %ebx,%esi
  102653:	89 c1                	mov    %eax,%ecx
  102655:	fd                   	std    
  102656:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  102658:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  102659:	eb 45                	jmp    1026a0 <memmove+0xd0>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10265b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10265e:	83 e0 03             	and    $0x3,%eax
  102661:	85 c0                	test   %eax,%eax
  102663:	75 2b                	jne    102690 <memmove+0xc0>
  102665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102668:	83 e0 03             	and    $0x3,%eax
  10266b:	85 c0                	test   %eax,%eax
  10266d:	75 21                	jne    102690 <memmove+0xc0>
  10266f:	8b 45 10             	mov    0x10(%ebp),%eax
  102672:	83 e0 03             	and    $0x3,%eax
  102675:	85 c0                	test   %eax,%eax
  102677:	75 17                	jne    102690 <memmove+0xc0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  102679:	8b 45 10             	mov    0x10(%ebp),%eax
  10267c:	89 c1                	mov    %eax,%ecx
  10267e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  102681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102684:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102687:	89 c7                	mov    %eax,%edi
  102689:	89 d6                	mov    %edx,%esi
  10268b:	fc                   	cld    
  10268c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10268e:	eb 10                	jmp    1026a0 <memmove+0xd0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  102690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102693:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102696:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102699:	89 c7                	mov    %eax,%edi
  10269b:	89 d6                	mov    %edx,%esi
  10269d:	fc                   	cld    
  10269e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  1026a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1026a3:	83 c4 10             	add    $0x10,%esp
  1026a6:	5b                   	pop    %ebx
  1026a7:	5e                   	pop    %esi
  1026a8:	5f                   	pop    %edi
  1026a9:	5d                   	pop    %ebp
  1026aa:	c3                   	ret    

001026ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  1026ab:	55                   	push   %ebp
  1026ac:	89 e5                	mov    %esp,%ebp
  1026ae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  1026b1:	8b 45 10             	mov    0x10(%ebp),%eax
  1026b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1026b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1026bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1026bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1026c2:	89 04 24             	mov    %eax,(%esp)
  1026c5:	e8 06 ff ff ff       	call   1025d0 <memmove>
}
  1026ca:	c9                   	leave  
  1026cb:	c3                   	ret    

001026cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  1026cc:	55                   	push   %ebp
  1026cd:	89 e5                	mov    %esp,%ebp
  1026cf:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  1026d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1026d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  1026d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1026db:	89 45 fc             	mov    %eax,-0x4(%ebp)

	while (n-- > 0) {
  1026de:	eb 32                	jmp    102712 <memcmp+0x46>
		if (*s1 != *s2)
  1026e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1026e3:	0f b6 10             	movzbl (%eax),%edx
  1026e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1026e9:	0f b6 00             	movzbl (%eax),%eax
  1026ec:	38 c2                	cmp    %al,%dl
  1026ee:	74 1a                	je     10270a <memcmp+0x3e>
			return (int) *s1 - (int) *s2;
  1026f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1026f3:	0f b6 00             	movzbl (%eax),%eax
  1026f6:	0f b6 d0             	movzbl %al,%edx
  1026f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1026fc:	0f b6 00             	movzbl (%eax),%eax
  1026ff:	0f b6 c0             	movzbl %al,%eax
  102702:	89 d1                	mov    %edx,%ecx
  102704:	29 c1                	sub    %eax,%ecx
  102706:	89 c8                	mov    %ecx,%eax
  102708:	eb 1c                	jmp    102726 <memcmp+0x5a>
		s1++, s2++;
  10270a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  10270e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  102712:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102716:	0f 95 c0             	setne  %al
  102719:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10271d:	84 c0                	test   %al,%al
  10271f:	75 bf                	jne    1026e0 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  102721:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102726:	c9                   	leave  
  102727:	c3                   	ret    

00102728 <memchr>:

void *
memchr(const void *s, int c, size_t n)
{
  102728:	55                   	push   %ebp
  102729:	89 e5                	mov    %esp,%ebp
  10272b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  10272e:	8b 45 10             	mov    0x10(%ebp),%eax
  102731:	8b 55 08             	mov    0x8(%ebp),%edx
  102734:	8d 04 02             	lea    (%edx,%eax,1),%eax
  102737:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  10273a:	eb 16                	jmp    102752 <memchr+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  10273c:	8b 45 08             	mov    0x8(%ebp),%eax
  10273f:	0f b6 10             	movzbl (%eax),%edx
  102742:	8b 45 0c             	mov    0xc(%ebp),%eax
  102745:	38 c2                	cmp    %al,%dl
  102747:	75 05                	jne    10274e <memchr+0x26>
			return (void *) s;
  102749:	8b 45 08             	mov    0x8(%ebp),%eax
  10274c:	eb 11                	jmp    10275f <memchr+0x37>

void *
memchr(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  10274e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102752:	8b 45 08             	mov    0x8(%ebp),%eax
  102755:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  102758:	72 e2                	jb     10273c <memchr+0x14>
		if (*(const unsigned char *) s == (unsigned char) c)
			return (void *) s;
	return NULL;
  10275a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10275f:	c9                   	leave  
  102760:	c3                   	ret    
  102761:	90                   	nop
  102762:	90                   	nop
  102763:	90                   	nop
  102764:	90                   	nop
  102765:	90                   	nop
  102766:	90                   	nop
  102767:	90                   	nop
  102768:	90                   	nop
  102769:	90                   	nop
  10276a:	90                   	nop
  10276b:	90                   	nop
  10276c:	90                   	nop
  10276d:	90                   	nop
  10276e:	90                   	nop
  10276f:	90                   	nop

00102770 <__udivdi3>:
  102770:	55                   	push   %ebp
  102771:	89 e5                	mov    %esp,%ebp
  102773:	57                   	push   %edi
  102774:	56                   	push   %esi
  102775:	83 ec 10             	sub    $0x10,%esp
  102778:	8b 45 14             	mov    0x14(%ebp),%eax
  10277b:	8b 55 08             	mov    0x8(%ebp),%edx
  10277e:	8b 75 10             	mov    0x10(%ebp),%esi
  102781:	8b 7d 0c             	mov    0xc(%ebp),%edi
  102784:	85 c0                	test   %eax,%eax
  102786:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102789:	75 35                	jne    1027c0 <__udivdi3+0x50>
  10278b:	39 fe                	cmp    %edi,%esi
  10278d:	77 61                	ja     1027f0 <__udivdi3+0x80>
  10278f:	85 f6                	test   %esi,%esi
  102791:	75 0b                	jne    10279e <__udivdi3+0x2e>
  102793:	b8 01 00 00 00       	mov    $0x1,%eax
  102798:	31 d2                	xor    %edx,%edx
  10279a:	f7 f6                	div    %esi
  10279c:	89 c6                	mov    %eax,%esi
  10279e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1027a1:	31 d2                	xor    %edx,%edx
  1027a3:	89 f8                	mov    %edi,%eax
  1027a5:	f7 f6                	div    %esi
  1027a7:	89 c7                	mov    %eax,%edi
  1027a9:	89 c8                	mov    %ecx,%eax
  1027ab:	f7 f6                	div    %esi
  1027ad:	89 c1                	mov    %eax,%ecx
  1027af:	89 fa                	mov    %edi,%edx
  1027b1:	89 c8                	mov    %ecx,%eax
  1027b3:	83 c4 10             	add    $0x10,%esp
  1027b6:	5e                   	pop    %esi
  1027b7:	5f                   	pop    %edi
  1027b8:	5d                   	pop    %ebp
  1027b9:	c3                   	ret    
  1027ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1027c0:	39 f8                	cmp    %edi,%eax
  1027c2:	77 1c                	ja     1027e0 <__udivdi3+0x70>
  1027c4:	0f bd d0             	bsr    %eax,%edx
  1027c7:	83 f2 1f             	xor    $0x1f,%edx
  1027ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1027cd:	75 39                	jne    102808 <__udivdi3+0x98>
  1027cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  1027d2:	0f 86 a0 00 00 00    	jbe    102878 <__udivdi3+0x108>
  1027d8:	39 f8                	cmp    %edi,%eax
  1027da:	0f 82 98 00 00 00    	jb     102878 <__udivdi3+0x108>
  1027e0:	31 ff                	xor    %edi,%edi
  1027e2:	31 c9                	xor    %ecx,%ecx
  1027e4:	89 c8                	mov    %ecx,%eax
  1027e6:	89 fa                	mov    %edi,%edx
  1027e8:	83 c4 10             	add    $0x10,%esp
  1027eb:	5e                   	pop    %esi
  1027ec:	5f                   	pop    %edi
  1027ed:	5d                   	pop    %ebp
  1027ee:	c3                   	ret    
  1027ef:	90                   	nop
  1027f0:	89 d1                	mov    %edx,%ecx
  1027f2:	89 fa                	mov    %edi,%edx
  1027f4:	89 c8                	mov    %ecx,%eax
  1027f6:	31 ff                	xor    %edi,%edi
  1027f8:	f7 f6                	div    %esi
  1027fa:	89 c1                	mov    %eax,%ecx
  1027fc:	89 fa                	mov    %edi,%edx
  1027fe:	89 c8                	mov    %ecx,%eax
  102800:	83 c4 10             	add    $0x10,%esp
  102803:	5e                   	pop    %esi
  102804:	5f                   	pop    %edi
  102805:	5d                   	pop    %ebp
  102806:	c3                   	ret    
  102807:	90                   	nop
  102808:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10280c:	89 f2                	mov    %esi,%edx
  10280e:	d3 e0                	shl    %cl,%eax
  102810:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102813:	b8 20 00 00 00       	mov    $0x20,%eax
  102818:	2b 45 f4             	sub    -0xc(%ebp),%eax
  10281b:	89 c1                	mov    %eax,%ecx
  10281d:	d3 ea                	shr    %cl,%edx
  10281f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  102823:	0b 55 ec             	or     -0x14(%ebp),%edx
  102826:	d3 e6                	shl    %cl,%esi
  102828:	89 c1                	mov    %eax,%ecx
  10282a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  10282d:	89 fe                	mov    %edi,%esi
  10282f:	d3 ee                	shr    %cl,%esi
  102831:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  102835:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102838:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10283b:	d3 e7                	shl    %cl,%edi
  10283d:	89 c1                	mov    %eax,%ecx
  10283f:	d3 ea                	shr    %cl,%edx
  102841:	09 d7                	or     %edx,%edi
  102843:	89 f2                	mov    %esi,%edx
  102845:	89 f8                	mov    %edi,%eax
  102847:	f7 75 ec             	divl   -0x14(%ebp)
  10284a:	89 d6                	mov    %edx,%esi
  10284c:	89 c7                	mov    %eax,%edi
  10284e:	f7 65 e8             	mull   -0x18(%ebp)
  102851:	39 d6                	cmp    %edx,%esi
  102853:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102856:	72 30                	jb     102888 <__udivdi3+0x118>
  102858:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10285b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10285f:	d3 e2                	shl    %cl,%edx
  102861:	39 c2                	cmp    %eax,%edx
  102863:	73 05                	jae    10286a <__udivdi3+0xfa>
  102865:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  102868:	74 1e                	je     102888 <__udivdi3+0x118>
  10286a:	89 f9                	mov    %edi,%ecx
  10286c:	31 ff                	xor    %edi,%edi
  10286e:	e9 71 ff ff ff       	jmp    1027e4 <__udivdi3+0x74>
  102873:	90                   	nop
  102874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102878:	31 ff                	xor    %edi,%edi
  10287a:	b9 01 00 00 00       	mov    $0x1,%ecx
  10287f:	e9 60 ff ff ff       	jmp    1027e4 <__udivdi3+0x74>
  102884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102888:	8d 4f ff             	lea    -0x1(%edi),%ecx
  10288b:	31 ff                	xor    %edi,%edi
  10288d:	89 c8                	mov    %ecx,%eax
  10288f:	89 fa                	mov    %edi,%edx
  102891:	83 c4 10             	add    $0x10,%esp
  102894:	5e                   	pop    %esi
  102895:	5f                   	pop    %edi
  102896:	5d                   	pop    %ebp
  102897:	c3                   	ret    
  102898:	90                   	nop
  102899:	90                   	nop
  10289a:	90                   	nop
  10289b:	90                   	nop
  10289c:	90                   	nop
  10289d:	90                   	nop
  10289e:	90                   	nop
  10289f:	90                   	nop

001028a0 <__umoddi3>:
  1028a0:	55                   	push   %ebp
  1028a1:	89 e5                	mov    %esp,%ebp
  1028a3:	57                   	push   %edi
  1028a4:	56                   	push   %esi
  1028a5:	83 ec 20             	sub    $0x20,%esp
  1028a8:	8b 55 14             	mov    0x14(%ebp),%edx
  1028ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1028ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  1028b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  1028b4:	85 d2                	test   %edx,%edx
  1028b6:	89 c8                	mov    %ecx,%eax
  1028b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  1028bb:	75 13                	jne    1028d0 <__umoddi3+0x30>
  1028bd:	39 f7                	cmp    %esi,%edi
  1028bf:	76 3f                	jbe    102900 <__umoddi3+0x60>
  1028c1:	89 f2                	mov    %esi,%edx
  1028c3:	f7 f7                	div    %edi
  1028c5:	89 d0                	mov    %edx,%eax
  1028c7:	31 d2                	xor    %edx,%edx
  1028c9:	83 c4 20             	add    $0x20,%esp
  1028cc:	5e                   	pop    %esi
  1028cd:	5f                   	pop    %edi
  1028ce:	5d                   	pop    %ebp
  1028cf:	c3                   	ret    
  1028d0:	39 f2                	cmp    %esi,%edx
  1028d2:	77 4c                	ja     102920 <__umoddi3+0x80>
  1028d4:	0f bd ca             	bsr    %edx,%ecx
  1028d7:	83 f1 1f             	xor    $0x1f,%ecx
  1028da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  1028dd:	75 51                	jne    102930 <__umoddi3+0x90>
  1028df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  1028e2:	0f 87 e0 00 00 00    	ja     1029c8 <__umoddi3+0x128>
  1028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028eb:	29 f8                	sub    %edi,%eax
  1028ed:	19 d6                	sbb    %edx,%esi
  1028ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1028f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028f5:	89 f2                	mov    %esi,%edx
  1028f7:	83 c4 20             	add    $0x20,%esp
  1028fa:	5e                   	pop    %esi
  1028fb:	5f                   	pop    %edi
  1028fc:	5d                   	pop    %ebp
  1028fd:	c3                   	ret    
  1028fe:	66 90                	xchg   %ax,%ax
  102900:	85 ff                	test   %edi,%edi
  102902:	75 0b                	jne    10290f <__umoddi3+0x6f>
  102904:	b8 01 00 00 00       	mov    $0x1,%eax
  102909:	31 d2                	xor    %edx,%edx
  10290b:	f7 f7                	div    %edi
  10290d:	89 c7                	mov    %eax,%edi
  10290f:	89 f0                	mov    %esi,%eax
  102911:	31 d2                	xor    %edx,%edx
  102913:	f7 f7                	div    %edi
  102915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102918:	f7 f7                	div    %edi
  10291a:	eb a9                	jmp    1028c5 <__umoddi3+0x25>
  10291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102920:	89 c8                	mov    %ecx,%eax
  102922:	89 f2                	mov    %esi,%edx
  102924:	83 c4 20             	add    $0x20,%esp
  102927:	5e                   	pop    %esi
  102928:	5f                   	pop    %edi
  102929:	5d                   	pop    %ebp
  10292a:	c3                   	ret    
  10292b:	90                   	nop
  10292c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102930:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  102934:	d3 e2                	shl    %cl,%edx
  102936:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102939:	ba 20 00 00 00       	mov    $0x20,%edx
  10293e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  102941:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102944:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  102948:	89 fa                	mov    %edi,%edx
  10294a:	d3 ea                	shr    %cl,%edx
  10294c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  102950:	0b 55 f4             	or     -0xc(%ebp),%edx
  102953:	d3 e7                	shl    %cl,%edi
  102955:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  102959:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10295c:	89 f2                	mov    %esi,%edx
  10295e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  102961:	89 c7                	mov    %eax,%edi
  102963:	d3 ea                	shr    %cl,%edx
  102965:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  102969:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10296c:	89 c2                	mov    %eax,%edx
  10296e:	d3 e6                	shl    %cl,%esi
  102970:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  102974:	d3 ea                	shr    %cl,%edx
  102976:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  10297a:	09 d6                	or     %edx,%esi
  10297c:	89 f0                	mov    %esi,%eax
  10297e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  102981:	d3 e7                	shl    %cl,%edi
  102983:	89 f2                	mov    %esi,%edx
  102985:	f7 75 f4             	divl   -0xc(%ebp)
  102988:	89 d6                	mov    %edx,%esi
  10298a:	f7 65 e8             	mull   -0x18(%ebp)
  10298d:	39 d6                	cmp    %edx,%esi
  10298f:	72 2b                	jb     1029bc <__umoddi3+0x11c>
  102991:	39 c7                	cmp    %eax,%edi
  102993:	72 23                	jb     1029b8 <__umoddi3+0x118>
  102995:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  102999:	29 c7                	sub    %eax,%edi
  10299b:	19 d6                	sbb    %edx,%esi
  10299d:	89 f0                	mov    %esi,%eax
  10299f:	89 f2                	mov    %esi,%edx
  1029a1:	d3 ef                	shr    %cl,%edi
  1029a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1029a7:	d3 e0                	shl    %cl,%eax
  1029a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1029ad:	09 f8                	or     %edi,%eax
  1029af:	d3 ea                	shr    %cl,%edx
  1029b1:	83 c4 20             	add    $0x20,%esp
  1029b4:	5e                   	pop    %esi
  1029b5:	5f                   	pop    %edi
  1029b6:	5d                   	pop    %ebp
  1029b7:	c3                   	ret    
  1029b8:	39 d6                	cmp    %edx,%esi
  1029ba:	75 d9                	jne    102995 <__umoddi3+0xf5>
  1029bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  1029bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  1029c2:	eb d1                	jmp    102995 <__umoddi3+0xf5>
  1029c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1029c8:	39 f2                	cmp    %esi,%edx
  1029ca:	0f 82 18 ff ff ff    	jb     1028e8 <__umoddi3+0x48>
  1029d0:	e9 1d ff ff ff       	jmp    1028f2 <__umoddi3+0x52>
