
//#include "espmissingincludes.h"
//#include "ets_sys.h"
//#include "osapi.h"
#include "stdout.h"
//#include "uart.h"

//#include "platform_config.h"
#include "jsinteractive.h"
#include "jshardware.h"

#include "jsvar.h"
#include "jswrap_functions.h"
//#include "spi_flash.h"

#import <Cocoa/Cocoa.h>

char uart0Buff[4096];
char *uart0Ptr = uart0Buff;

void uart0_putc(const char c) {
	if (c == '\n') {
		*uart0Ptr = 0;
		NSLog(@"%s", uart0Buff);
		uart0Ptr = uart0Buff;
	}
	else if (c != '\r')
		*uart0Ptr++ = c;
}

// error handler for pure virtual calls
void __cxa_pure_virtual() { while (1); }

void jsInit(bool autoLoad) {
    jshInit();
    jsvInit();
	jsiInit(autoLoad);
}
void jsKill() {
	jsiKill();
	jsvKill();
	jshKill();
}

void printTime(JsSysTime time) {
	JsVarFloat ms = jshGetMillisecondsFromTime(time);
	jsiConsolePrintf("time: %d, %f, %d\n", (int)time, ms, (int)jshGetTimeFromMilliseconds(ms));
}
void printMilliseconds(JsVarFloat ms) {
	JsSysTime time = jshGetTimeFromMilliseconds(ms);
	jsiConsolePrintf("ms: %f, %d, %f\n", ms, (int)time, jshGetMillisecondsFromTime(time));
}

void test() {
	JsSysTime time = 1;
	for (int n = 0; n < 15; n++) {
		printTime(time);
		printTime(time/10);
		time *= 10;
	}
	JsVarFloat ms = 1.0;
	for (int n = 0; n < 15; n++) {
		printMilliseconds(ms);
		printMilliseconds(ms / 10.0);
		ms *= 10.0;
	}
}

//JsVar *jswrap_interface_setInterval(JsVar *func, JsVarFloat timeout);
JsVar *prototype1(JsVar *v1, JsVarFloat f1) {
	jsiConsolePrintf("%v, %d\n", v1, (int)f1);
	return 0;
}
JsVar *prototype2(JsVar *v1, JsVar *v2, JsVarFloat f1, JsVarFloat f2) {
	jsiConsolePrintf("%v, %v, %d, %d\n", v1, v2, (int)f1, (int)f2);
	return 0;
}
JsVar *prototype3(JsVar *v1, JsVar *v2, JsVar *v3, JsVarFloat f1, JsVarFloat f2, JsVarFloat f3) {
	jsiConsolePrintf("%v, %v, %v, %d, %d, %d\n", v1, v2, v3, (int)f1, (int)f2, (int)f3);
	return 0;
}
JsVar *prototype4(JsVar *v1, JsVar *v2, JsVar *v3, JsVar *v4, JsVarFloat f1, JsVarFloat f2, JsVarFloat f3, JsVarFloat f4) {
	jsiConsolePrintf("%v, %v, %v, %v, %d, %d, %d, %d\n", v1, v2, v3, v4, (int)f1, (int)f2, (int)f3, (int)f4);
	return 0;
}

void functionCall4(void *function, JsVar *v1, JsVar *v2, JsVar *v3, JsVar *v4, JsVar *v5, JsVar *v6, JsVar *v7, JsVar *v8) {
	size_t d[] = {(size_t)v1, (size_t)v2, (size_t)v3, (size_t)v4};
	JsVarFloat f[] = {jsvGetFloat(v5), jsvGetFloat(v6), jsvGetFloat(v7), jsvGetFloat(v8)};
	
	((uint64_t (*) (
					size_t,
					size_t,
					JsVarFloat,
					JsVarFloat
					))function) (
								 d[0],
								 d[1],
								 f[0],
								 f[1]
								 );
}

void functionCall8(void *function, JsVar *v1, JsVar *v2, JsVar *v3, JsVar *v4, JsVar *v5, JsVar *v6, JsVar *v7, JsVar *v8) {
	size_t d[] = {(size_t)v1, (size_t)v2, (size_t)v3, (size_t)v4};
	JsVarFloat f[] = {jsvGetFloat(v5), jsvGetFloat(v6), jsvGetFloat(v7), jsvGetFloat(v8)};
	
	((uint64_t (*) (
					size_t,
					size_t,
					size_t,
					size_t,
					JsVarFloat,
					JsVarFloat,
					JsVarFloat,
					JsVarFloat
					))function) (
								 d[0],
								 d[1],
								 d[2],
								 d[3],
								 f[0],
								 f[1],
								 f[2],
								 f[3]
								 );
}

void testFunctionCall() {
	JsVar *v[] = {
		jsvNewFromFloat(11.0), jsvNewFromFloat(12.0), jsvNewFromFloat(13.0), jsvNewFromFloat(14.0),
		jsvNewFromFloat(15.0), jsvNewFromFloat(16.0), jsvNewFromFloat(17.0), jsvNewFromFloat(18.0)
	};
	
	functionCall4(prototype1, v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
	functionCall4(prototype2, v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
	functionCall8(prototype3, v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
	functionCall8(prototype4, v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
}

void jsRun(const char *code) {
	test();
	
	jsInit(code ? false : true);
//	addNativeFunction("quit", nativeQuit);

	testFunctionCall();

	if (code) {
		JsVar *result = jspEvaluate(code, true);
		if (result) {
			jsiConsolePrintf("%v\n", result);
			jsvUnLock(result);
		}
	}
	JsVar *exception = jspGetException();
	if (exception) {
		jsiConsolePrintf("Uncaught %v\n", exception);
		jsvUnLock(exception);
	} else if (jspIsInterrupted()) {
		jsiConsoleRemoveInputLine();
		jsiConsolePrint("Execution Interrupted.\n");
		jspSetInterrupted(false);
	} else {
		bool working = true;
		while (jsiHasTimers() || working)
			working = jsiLoop();
	}
	jsKill();
}

#define ICACHE_RAM_ATTR

const char *ICACHE_RAM_ATTR jsVarToString(JsVar *jsVar) {
	if (!jsVar) return "undefined";
	jsVar = jsvAsString(jsVar, true/*unlock*/);
	size_t len = jsvGetStringLength(jsVar);
	if (0 == len) return "''";
	static char *str = NULL;
	static size_t size = 0;
	if (!str) str = malloc(size = len+32);
	else if (size < len+1) {
		free(str);
		str = malloc(size = len+32);
	}
	len = jsvGetString(jsVar, str, size);
	str[len] = 0;
	return str ? str : "undefined";
}

