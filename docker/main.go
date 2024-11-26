package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"time"

	"github.com/fatih/color"
	"github.com/briandowns/spinner"
)

func main() {
	if len(os.Args) < 2 {
		showHelp()
		return
	}

	command := os.Args[1]
	checkDocker()
	switch command {
	case "--fresh-start":
		freshStart()
	case "--it":
		interactiveMode()
	case "--dev":
		devMode()
	case "--build-prod":
		buildProd()
	case "--run-prod":
		runProd()
	case "--down":
		cleanup()
	default:
		showHelp()
	}
}

func checkDocker() {
	if !commandExists("docker") {
		color.Red("Docker or Docker Compose is not installed. Please install them to proceed.")
		os.Exit(1)
	}
	color.Green("Docker and Docker Compose detected.")
}

func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

func showHelp() {
	color.Yellow(`
Usage:
  --fresh-start   Start with a fresh setup
  --it            Run in interactive mode
  --dev           Start development environment
  --build-prod    Build production image
  --run-prod      Run production environment
  --down          Stop and clean up
	`)
}

func freshStart() {
	color.Cyan("Starting with a fresh setup...")
	runSpinner(func() {
		runCommand("docker-compose", "-f", "docker/docker-compose.yml", "up", "init-project", "--build")
	}, "Setting up the project")
	color.Green("Fresh setup complete!")
	fmt.Println("You can start an interactive session with: ./tool --it")
}

func interactiveMode() {
	color.Cyan("Running in interactive mode...")
	runSpinner(func() {
		runCommand("docker", "exec", "-it", "laravel-app", "/bin/bash")
	}, "Starting interactive session")
}

func devMode() {
	color.Green("Dev Container Running...")
	fmt.Println(`
    Image: serversideup/php:8.3-fpm-nginx-bookworm
    Host: 127.0.0.1
    Port: 8000
	`)
	runSpinner(func() {
		runCommand("docker-compose", "-f", "docker/docker-compose.yml", "up", "-d", "php", "postgres")
	}, "Starting development environment")
	runCommand("docker", "exec", "-it", "laravel-app", "/bin/bash")
}

func buildProd() {
	color.Cyan(">>> Building production image...")
	runSpinner(func() {
		runCommand("docker", "build", "--cache-from", "serversideup/laravel:8.3-fpm-nginx-bookworm",
			"--build-arg", "BUILDKIT_INLINE_CACHE=1",
			"--target", "production",
			"--tag", "serversideup/laravel:8.3-fpm-nginx-bookworm",
			"--file", "docker/Dockerfile", ".")
	}, "Building production image")

	color.Green("Image built successfully!")
	fmt.Print("Do you want to proceed with running the production environment? (y/n): ")
	reader := bufio.NewReader(os.Stdin)
	response, _ := reader.ReadString('\n')
	if response == "y\n" || response == "Y\n" {
		runProd()
	} else {
		color.Red("Skipped running production environment.")
	}
}

func runProd() {
	color.Cyan(">>> Running production environment...")
	runSpinner(func() {
		runCommand("docker-compose", "-f", "docker/docker-compose.yml", "up", "-d", "prod", "postgres")
	}, "Starting production environment")
}

func cleanup() {
	color.Red("Stopping and cleaning up Docker containers...")
	runSpinner(func() {
		runCommand("docker-compose", "-f", "docker/docker-compose.yml", "down")
	}, "Cleaning up")
}

func runCommand(name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		color.Red("Error executing command: %v", err)
		os.Exit(1)
	}
}

func runSpinner(action func(), message string) {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond) // Choose a spinner style
	s.Suffix = " " + message
	s.Start()
	time.Sleep(1 * time.Second) // Simulate loading time
	action()
	s.Stop()
}
