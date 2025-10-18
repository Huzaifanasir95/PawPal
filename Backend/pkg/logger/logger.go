package logger

import (
	"log"
	"os"
	"time"
)

type Logger struct {
	infoLogger  *log.Logger
	errorLogger *log.Logger
	debugLogger *log.Logger
}

func NewLogger() *Logger {
	return &Logger{
		infoLogger:  log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile),
		errorLogger: log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile),
		debugLogger: log.New(os.Stdout, "DEBUG: ", log.Ldate|log.Ltime|log.Lshortfile),
	}
}

func (l *Logger) Info(message string) {
	l.infoLogger.Println(message)
}

func (l *Logger) Infof(format string, args ...interface{}) {
	l.infoLogger.Printf(format, args...)
}

func (l *Logger) Error(message string) {
	l.errorLogger.Println(message)
}

func (l *Logger) Errorf(format string, args ...interface{}) {
	l.errorLogger.Printf(format, args...)
}

func (l *Logger) Debug(message string) {
	if os.Getenv("DEBUG") == "true" {
		l.debugLogger.Println(message)
	}
}

func (l *Logger) Debugf(format string, args ...interface{}) {
	if os.Getenv("DEBUG") == "true" {
		l.debugLogger.Printf(format, args...)
	}
}

func (l *Logger) LogRequest(method, path string, status int, duration time.Duration) {
	l.Infof("%s %s - %d - %v", method, path, status, duration)
}