OUTPUT_ARCH("riscv")

ENTRY(_enter)

MEMORY
{
	ram (wxa!ri) : ORIGIN = 0x20000000, LENGTH = 0x8000000
}

PHDRS
{
	flash PT_LOAD;
	ram_init PT_LOAD;
	itim_init PT_LOAD;
	ram PT_LOAD;
	itim PT_LOAD;
}

SECTIONS
{
	__stack_size = DEFINED(__stack_size) ? __stack_size : 0x400;
	__heap_size = DEFINED(__heap_size) ? __heap_size : 0x400;


	.init 		:
	{
		KEEP (*(.text.metal.init.enter))
		KEEP (*(SORT_NONE(.init)))
		KEEP (*(.text.libgloss.start))
	} >ram AT>ram :ram


	.text 		:
	{
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.*)
		*(.itim .itim.*)
		*(.gnu.linkonce.t.*)
	} >ram AT>ram :ram


	.fini 		:
	{
		KEEP (*(SORT_NONE(.fini)))
	} >ram AT>ram :ram


	PROVIDE (__etext = .);
	PROVIDE (_etext = .);
	PROVIDE (etext = .);


	.rodata 		:
	{
		*(.rdata)
		*(.rodata .rodata.*)
		*(.gnu.linkonce.r.*)
	} >ram AT>ram :ram


	. = ALIGN(4);


	.preinit_array 		:
	{
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP (*(.preinit_array))
		PROVIDE_HIDDEN (__preinit_array_end = .);
	} >ram AT>ram :ram


	.init_array 		:
	{
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
		KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
		PROVIDE_HIDDEN (__init_array_end = .);
	} >ram AT>ram :ram


	.finit_array 		:
	{
		PROVIDE_HIDDEN (__finit_array_start = .);
		KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
		KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
		PROVIDE_HIDDEN (__finit_array_end = .);
	} >ram AT>ram :ram


	.ctors 		:
	{
		/* gcc uses crtbegin.o to find the start of
		   the constructors, so we make sure it is
		   first.  Because this is a wildcard, it
		   doesn't matter if the user does not
		   actually link against crtbegin.o; the
		   linker won't look for a file to match a
		   wildcard.  The wildcard also means that it
		   doesn't matter which directory crtbegin.o
		   is in.  */
		KEEP (*crtbegin.o(.ctors))
		KEEP (*crtbegin?.o(.ctors))
		/* We don't want to include the .ctor section from
		   the crtend.o file until after the sorted ctors.
		   The .ctor section from the crtend file contains the
		   end of ctors marker and it must be last */
		KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
		KEEP (*(SORT(.ctors.*)))
		KEEP (*(.ctors))
	} >ram AT>ram :ram


	.dtors 		:
	{
		KEEP (*crtbegin.o(.dtors))
		KEEP (*crtbegin?.o(.dtors))
		KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
		KEEP (*(SORT(.dtors.*)))
		KEEP (*(.dtors))
	} >ram AT>ram :ram


	.litimalign 		:
	{
		. = ALIGN(4);
		PROVIDE( metal_segment_itim_source_start = . );
	} >ram AT>ram :ram


	.ditimalign 		:
	{
		. = ALIGN(4);
		PROVIDE( metal_segment_itim_target_start = . );
	} >ram AT>ram :ram_init


	.itim 		:
	{
		*(.itim .itim.*)
	} >ram AT>ram :ram_init


	. = ALIGN(8);
	PROVIDE( metal_segment_itim_target_end = . );


	.lalign 		:
	{
		. = ALIGN(4);
		PROVIDE( _data_lma = . );
		PROVIDE( metal_segment_data_source_start = . );
	} >ram AT>ram :ram


	.dalign 		:
	{
		. = ALIGN(4);
		PROVIDE( metal_segment_data_target_start = . );
	} >ram AT>ram :ram_init


	.data 		:
	{
		*(.data .data.*)
		*(.gnu.linkonce.d.*)
		. = ALIGN(8);
		PROVIDE( __global_pointer$ = . + 0x800 );
		*(.sdata .sdata.* .sdata2.*)
		*(.gnu.linkonce.s.*)
		. = ALIGN(8);
		*(.srodata.cst16)
		*(.srodata.cst8)
		*(.srodata.cst4)
		*(.srodata.cst2)
		*(.srodata .srodata.*)
	} >ram AT>ram :ram_init


	. = ALIGN(4);
	PROVIDE( _edata = . );
	PROVIDE( edata = . );
	PROVIDE( metal_segment_data_target_end = . );
	PROVIDE( _fbss = . );
	PROVIDE( __bss_start = . );
	PROVIDE( metal_segment_bss_target_start = . );


	.bss 		:
	{
		*(.sbss*)
		*(.gnu.linkonce.sb.*)
		*(.bss .bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON)
		. = ALIGN(4);
	} >ram AT>ram :ram


	. = ALIGN(8);
	PROVIDE( _end = . );
	PROVIDE( end = . );
	PROVIDE( metal_segment_bss_target_end = . );


	.stack :
	{
		PROVIDE(metal_segment_stack_begin = .);
		. = __stack_size;
		PROVIDE( _sp = . );
		PROVIDE(metal_segment_stack_end = .);
	} >ram AT>ram :ram


	.heap :
	{
		PROVIDE( metal_segment_heap_target_start = . );
		. = __heap_size;
		PROVIDE( metal_segment_heap_target_end = . );
		PROVIDE( _heap_end = . );
	} >ram AT>ram :ram


}

