package main

import (
	"fmt"
	"runtime"
)

var (
	Version   string
	GitCommit string
	Branch    string
	BuildUser string
	BuildDate string
	GoVersion = runtime.Version()
)

func Info() string {
	return fmt.Sprintf("(version=%s, branch=%s, gitcommit=%s)", Version, Branch, GitCommit)
}

func BuildContext() string {
	return fmt.Sprintf("(go=%s, user=%s, date=%s)", GoVersion, BuildUser, BuildDate)
}