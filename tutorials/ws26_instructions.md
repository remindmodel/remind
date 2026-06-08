# REMIND Workshop 2026

- [REMIND Workshop 2026](#remind-workshop-2026)
  - [1. Install Docker](#1-install-docker)
  - [2. Download the container](#2-download-the-container)
  - [3. Basic Docker operations](#3-basic-docker-operations)
    - [Docker Desktop](#docker-desktop)
    - [Command line](#command-line)
  - [4. Running REMIND](#4-running-remind)
    - [Quick test](#quick-test)
    - [Workshop scenarios](#workshop-scenarios)
    - [Copy results to your machine](#copy-results-to-your-machine)
  - [5. Running on AWS EC2](#5-running-on-aws-ec2)
    - [Launch an instance](#launch-an-instance)
    - [First-time setup](#first-time-setup)
    - [Pull and run](#pull-and-run)
    - [Retrieve results](#retrieve-results)

---

The workshop runs REMIND from a pre-built Docker container. Think of a container as a self-contained box that holds a complete computing environment: the right version of R, GAMS, all required packages, input data, and the GAMS license. You download the box once and run it on your machine without installing any of those components separately.

---

## 1. Install Docker

Docker is the software that runs the container on your machine. Install it once; you do not need to reinstall it for future workshops.

**Windows and Mac:** Download [Docker Desktop](https://www.docker.com/products/docker-desktop/) and run the installer. Docker Desktop provides both a graphical interface and the command-line tools used in the rest of this guide. No further configuration is needed after installation.

**Linux (Ubuntu/Debian):** Open a terminal and run:
```bash
sudo apt-get install docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

The `usermod` command adds your user to the `docker` group so you can run Docker commands without `sudo`. Log out and back in for that change to take effect. You can verify it worked by running `docker ps` without `sudo` and seeing an empty list instead of a permission error.

**Podman (untested alternative):** [Podman](https://podman.io/) is a drop-in replacement for Docker that does not require administrator privileges and has no background service. Most Docker commands work identically -- just replace `docker` with `podman`. We have not tested the workshop container with Podman, so if you run into problems, fall back to Docker.

---

## 2. Download the container

The workshop container image is published at [ghcr.io/remindmodel/remind-box](https://github.com/orgs/remindmodel/packages/container/package/remind-box). Open a terminal and run:

```
docker pull ghcr.io/remindmodel/remind-box:ws26
```

`pull` downloads the image from the internet to your machine. The image is several gigabytes, so this may take a few minutes on a fast connection. You only need to do this once. The image stays on your machine until you explicitly remove it.

The `ws26` part at the end is the image tag -- it identifies the specific version built for the 2026 workshop.

---

## 3. Basic Docker operations

There are two ways to work with Docker: the Docker Desktop graphical interface and the command line. Both give you access to the same containers. Use whichever you are more comfortable with. The command line is described in more detail because it is the same on Windows, Mac, and Linux.

### Docker Desktop

1. Open Docker Desktop. The **Images** tab lists all images you have downloaded, including `remind-box`.
2. Click **Run** next to `remind-box:ws26`. In the dialog that appears, expand **Optional settings** and set a container name such as `ws26`. Leave all other fields empty and click **Run**.
3. Your container appears in the **Containers** tab with a green status indicator. Click on it to open the detail view.
4. The **Logs** tab shows everything the container has printed so far. The **Terminal** tab (or **Exec** button, depending on your version) opens a shell inside the running container -- this is where you will type REMIND commands.
5. Once you have a terminal inside the container, continue from the [Running REMIND](#4-running-remind) section.

### Command line

Open a terminal (PowerShell on Windows, Terminal on Mac, any shell on Linux). The Docker commands are the same on all platforms.

**Start an idle container in the background.** The `sleep infinity` command keeps the container running without doing anything, so you can attach to it whenever you need:
```
docker run -d --name ws26 ghcr.io/remindmodel/remind-box:ws26 sleep infinity
```
`-d` runs the container in the background (detached). `--name ws26` gives it a memorable name so you do not have to use the container ID in subsequent commands. If you see an error saying the name is already in use, a container with that name already exists -- see the stop and remove commands below.

**Open an interactive shell inside the running container:**
```
docker exec -it ws26 bash
```
`exec` runs a command inside an already-running container. `-it` connects your terminal to that command so you can type and see output. `bash` is the shell you are opening. Your prompt changes to something like `root@abc123:/# `, which means you are now inside the container.

**List running containers** to check whether your container is up:
```
docker ps
```

**Stop the container** when you are done for the day:
```
docker stop ws26
```

**Start it again** the next day without re-downloading:
```
docker start ws26
```

**Remove the container entirely** (this deletes any files written inside it, including REMIND output):
```
docker rm ws26
```

To start fresh, remove the container and run the `docker run` command again.

---

## 4. Running REMIND

Start an idle container and open a shell inside it (if you have not already done so):

```
docker run -d --name ws26 ghcr.io/remindmodel/remind-box:ws26 sleep infinity
docker exec -it ws26 bash
```

You are now inside the container. Navigate to the REMIND directory:

```
cd /opt/remind
```

All REMIND commands in this section are typed from that directory, inside the container. Keep this terminal window open for the duration of the run. If you close it, REMIND will stop.

### Quick test

Before running the full workshop scenarios, run a quick test to verify that your container and GAMS license are working correctly. The `--testOneRegi` flag tells REMIND to solve a single world region for a single iteration -- enough to exercise GAMS without waiting hours.

```
Rscript start.R --testOneRegi
```

REMIND will print setup messages as it loads R packages and compiles the GAMS model file:

```
2026-11-13 14:48:01: Creating full.gms
2026-11-13 14:48:15: unlocked model.

Starting REMIND...
GAMS will provide logging in full.log.
```

Once GAMS starts, it writes its progress to a separate log file rather than to your terminal. To watch that log, open a **second terminal** on your host machine and run:

```
docker exec -it ws26 bash
tail -f /opt/remind/output/testOneRegi/full.log
```

`tail -f` follows the file and prints new lines as they are added. Press Ctrl-C to stop watching -- this only stops `tail`, not the REMIND run itself.

When the test finishes, REMIND prints a summary in your first terminal:

```
Model summary:
  gams_runtime is 43.5 mins.
  full.gms exists, so the REMIND GAMS code was generated.
  full.log and full.lst exist, so GAMS did run.
  abort.gdx does not exist, a file written automatically for some types of errors.
  non_optimal.gdx exists, because iteration 1 did not find a locally optimal solution. modelstat: 7
! fulldata.gdx does not exist, so output generation will fail.
  Modelstat after 1 iterations: 7 (Intermediate Nonoptimal)
  full.log states: *** Status: Normal completion
```

Two things in this summary look alarming but are expected for this test run:

- `non_optimal.gdx` and `modelstat: 7`: the single-iteration test does not have enough iterations to converge. In a real run, the model solves repeatedly until it converges.
- `fulldata.gdx does not exist`: the full output file is only written when the model converges. The test intentionally skips that.

The important line is `*** Status: Normal completion`, which means GAMS finished without crashing. If you see that, your setup is working.

You can safely ignore messages like:

```
Cannot access run statistics repository /p/projects/rd3mod/...
Run statistics are not submitted.
```

That path exists only on the PIK computing cluster and is not reachable from your container.

### Workshop scenarios

The workshop uses two scenarios:

- `SSP2-NPi2025` -- the reference run. No additional climate policies beyond those in place as of 2025. This runs first.
- `SSP2-PkBudg750` -- a climate policy run targeting a 750 Gt CO2 remaining carbon budget. It uses the results of the reference run as a starting point, so it can only run after `SSP2-NPi2025` finishes.

Both are configured in `config/scenario_config_ws26.csv` and start with one command:

```
Rscript start.R config/scenario_config_ws26.csv
```

Leave this terminal open during the entire REMIND run. It works by iterating between an energy system model, the [transport model](https://github.com/ahagen-pik/edgeTransport/) and a macro-economic model until they agree on prices and quantities. Each round of this back-and-forth is a Nash iteration. You will see lines like:

```
--- LOOPS iteration = 12
```

printed as the run progresses. Convergence typically takes 30-50 iterations. The reference scenario usually runs approx. 4 hours depending on your machine. The policy scenario follows automatically and takes a similar amount of time. To watch the GAMS solver log in a second terminal while the run is ongoing:

```
docker exec -it ws26 bash
ls -t /opt/remind/output/
tail -f /opt/remind/output/<most-recent-folder>/full.log
```

Replace `<most-recent-folder>` with the folder name shown by `ls -t` (it will start with `SSP2-NPi2025` or `SSP2-PkBudg750` followed by a timestamp).

When both scenarios have finished, the final lines printed for each will include:

```
--- LOOPS iteration = 44
*** Status: Normal completion
```

Output is written to timestamped folders under `/opt/remind/output/`, for example:

```
SSP2-NPi2025_2026-11-13_14.00.00/
SSP2-PkBudg750_2026-11-13_18.28.33/
```

### Copy results to your machine

Run this command in a terminal on your **host machine** (not inside the container):

```
docker cp ws26:/opt/remind/output ./output
```

This copies everything from the container's output directory into a local `output` folder in your current working directory. You can then open the `.mif` and `.gdx` files in R for analysis.

---

## 5. Running on AWS EC2

The full workshop scenarios take several hours. If you do not want to run them on your laptop, you can use a cloud virtual machine on a cloud computing provider like [Amazon Web Services (AWS)](https://aws.amazon.com/). The REMIND container runs identically there with the only difference being that the machine is remote and you connect to it over SSH.

Ask the workshop organizers if you need an AWS account or access credentials.

### Launch an instance

Log in to the [AWS Console](https://console.aws.amazon.com/) and navigate to EC2. Launch a new instance with the following settings:

- **Instance type:** `c6i.4xlarge` (16 vCPU, 32 GB RAM)
- **Region:** `eu-north-1` (or whatever is convenient for your location)
- **Operating system:** Amazon Linux 2023
- **Key pair:** create or select an existing SSH key pair and download the `.pem` file to your machine

Note the public IP address of the instance after it starts.

### First-time setup

Connect to the instance over SSH and install Docker:

```bash
ssh -i your-key.pem ec2-user@<ip>
sudo dnf install -y docker htop awscli
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
```

Log out and SSH back in so the docker group takes effect:

```bash
exit
ssh -i your-key.pem ec2-user@<ip>
```

Verify Docker is working:

```bash
docker ps
```

### Pull and run

Pull the workshop image and start the scenarios:

```bash
docker pull ghcr.io/remindmodel/remind-box:ws26
docker run -d --name ws26 ghcr.io/remindmodel/remind-box:ws26 sleep infinity
docker exec -d ws26 bash -c "cd /opt/remind && Rscript start.R config/scenario_config_ws26.csv > /var/log/remind/scenarios.log 2>&1"
```

Note that on EC2 we use `docker exec -d` (detached) instead of the interactive shell approach, because the run will take hours and we do not want it to stop if our SSH connection drops.

Follow the log without keeping an SSH connection open:

```bash
ssh -i your-key.pem ec2-user@<ip> "docker exec ws26 tail -f /var/log/remind/scenarios.log"
```

You can run that command from your local machine, watch the log for a while, press Ctrl-C to disconnect, and re-run it later to check progress.

### Retrieve results

On the EC2 instance, copy output out of the container:

```bash
docker cp ws26:/opt/remind/output ~/output
```

Then from your local machine, copy it from EC2 to your computer:

```bash
scp -r -i your-key.pem ec2-user@<ip>:~/output ./output
```

When you are done, stop the EC2 instance in the AWS Console to avoid being charged for idle compute time.
