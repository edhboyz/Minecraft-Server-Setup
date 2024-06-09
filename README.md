# Minecraft-Server-Setup
Shell Scripts Automating the Creation of a Minecraft Server Using AWS Through the AWS CLI
### Step 1: Getting Started
An important note before we begin, this script was built with the intention of running on a git bash terminal on a Windows 10 device. I have not tested the script on any other devices. The only differences would be how you install the prerequisites before running the script.

#### Clone the repository onto your local machine

Navigate to the folder you'd like to store your minecraft script in, and run `git clone` with the https link found in the repository. If this process is confusing for you, check out https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository

#### Install AWS CLI
To install the Amazon Web Services Command Line Interface (AWS CLI) I used the Windows winget package manager. You can install the AWS CLI by runnning `winget search aws`, which should bring up all of the AWS packages that can be installed. Find the AWS Command Line Interface, and use it's ID in `winget install [ID]` with ID being the ID found by the search. At this time for me, it's `winget install Amazon.AWSCLI`. 

#### Install nmap
In the same fashion, we are going to use winget to install nmap. Run `winget search nmap` to find the ID, and `winget install Insecure.Nmap` (or other ID if you find it) to install it. If you are having issues with either of these steps, it should be easy to find resources online for other ways you can install these packages.

#### Configure AWS credentials
You need credentials with AWS to set up an instance to run the server. To modify them, naviagate to the aws credentials file with `cd ~/.aws/credentails` and open the file to edit using your favorite editor. Copy the aws_access_key_id, aws_secret_access_key, and aws_session_token into the credentials. If you run into any issues, look into them [here.](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-configure.html) Navigate back to the folder containing the script.

### Step 2: Run the Script

Run the script with `./MinecraftServerSetup.sh`. This should set up everything for you and finishes by checking if you can connect to the server using nmap. It will be successful if you see a message at the end of your terminal stating `Nmap done: 1 IP address .... scanned in ... seconds` Connect to the server through the IP address listed at the end of the script in the terminal. The rest of this section details how the script functions in case you need to debug something.

#### Creating a Key Pair
Our server runs an EC2 instance with Amazon Linux 2023. To connect to our instance we will need to authenticate with a key pair. The script creates a key pair using AWS CLI's [create-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html) command  with output redirected to a MinecraftKeyPair.pem file.

#### Creating Minecraft Security Group
We need a security group to control who has access to the minecraft server. We need to create a security group with AWS CLI's [create-security-group](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-security-group.html) command. This command is left empty to utilize the default VPC for the security group. If you have deleted the default VPC for any reason, go to the AWS console and add a default VPC.

We then modify the security group we created by adding two rules with [authorize-security-group-ingress](https://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html) The two rules we add are inbound rules which allow anyone to ssh to the instance provided they authenticate using the key and allow anyone to connect to the minecraft server on the port 25565 (default port for minecraft servers).

#### Creating the Instance
Now we have our parts needed to create the instance with [run-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html). Our instance is created on an Amazon Linux 2023 distribution with Arm (64 bit) on a t4g.small. We use the key pair and security group generated earlier and store the Instance ID so we can use it to get the IP from the instance. We then use [describe-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html) to get a description which we search through for teh Instance IP. These requests utilize the query found from JMESpath which is a part of AWS CLI. A tutorial I used to help figure out the queries is listed [here.](https://jmespath.org/tutorial.html)

### Configuring the Minecraft Server
Now we have an instance which can host a Minecraft Server. We just need to add a minecraft server to the instance. In order to do so, I followed [this guide](https://aws.amazon.com/blogs/gametech/setting-up-a-minecraft-java-server-on-amazon-ec2/) with some modifications to make the script run the process automatically. For those interested in checking out the guide to understand what each step is doing, at this point the script is starting on step 12. However it does not use the User Data field but runs the commands in the ssh session as using the User Data field for configuration is considered bad practice.

One important difficulty with this script is executing commands in the ssh session. In order to execute commands after sshing to the instance, I got help from [this stack overflow exchange](https://stackoverflow.com/questions/305035/how-to-use-ssh-to-run-a-local-shell-script-on-a-remote-machine). The only differences between the guide and the script is some of the manual configuration they recommend required automatic configuration. For example, the `eula.txt` file needs to have it's flag set from false to true. To modify the file through the script, the linux command [sed](https://linux.die.net/man/1/sed) was used.

