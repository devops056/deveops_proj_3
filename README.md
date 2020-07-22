# DevOps_Task_3 (Kubernetes + Dockerfile + Git + Jenkins + Testing)

## Project Tasks:
Perform below task on top of Kubernetes where we use Kubernetes resources like Pods, ReplicaSet, Deployment, PVC and Service.

1. Create container image that’s has Jenkins installed  using dockerfile  Or You can use the Jenkins Server on RHEL 8/7
2. When we launch this image, it should automatically starts Jenkins service in the container.
3. Create a job chain of job1, job2, job3 and  job4 using build pipeline plugin in Jenkins 
4. Job1 : Pull  the Github repo automatically when some developers push repo to Github.
5. Job2 : 
    a). By looking at the code or program file, Jenkins should automatically start the respective language interpreter installed image container to deploy code on top of Kubernetes ( eg. If code is of  PHP, then Jenkins should start the container that has PHP already installed )
    b).  Expose your pod so that testing team could perform the testing on the pod
    c). Make the data to remain persistent ( If server collects some data like logs, other user information )
6. Job3 : Test your app if it  is working or not.
7. Job4 : if app is not working , then send email to developer with error messages and redeploy the application after code is being edited by the developer

## Let's see step by step how to achieve this:

#### Step - 1 -Creat Dockerfile and Build Image, please find the below command, refer these snaps - (creating jenkins image, jenkins image created).
created Dockerfile as per uploded file and builded image using below command and also run it.
```
docker build -t myjenkins:v1 . (here"." means we are running this command from present directory of Dockerfile)
```

#### Step - 2 -Run that Image using below command, refer these snaps - (Jenkins docker run).
```
docker run -it -P -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker -v /root/.kube:/root/.kube --name myjenkins1 myjenkins:v1
```
(Note: we have attached docker socket and configuration file of base os to perfrom any commnad from jenkins container, -P is for exposing 8080 port)

#### Step - 3 - Login in url of jenkins using below command to find exposed port, please find the below command, refer these snaps - (initial password, Exposed port, use login url and initial password).
```
docker ps
```
-By using base os ip to open jenkins(http://192.168.99.101:32771/)

-Use default password shown in this file (/root/.jenkins/secrets/initialAdminPassword) 

-Change the admin password then create below jobs

#### Step - 4 - Job-1 -Pull the code from GitHub when developers pushed to Github using poll SCM, please find the below code, refer these snaps - (Github plugin installation, Job-1-snap-1, Job-1-snap-2).
-First of all, install GitHub plugin in jenkins from manage jenkins.

-pull the code from GitHub and run below command to copy those files from jenkins workspace to that folder
```
if ls /home/ | grep code
then
	echo "Directory already present"
else
	sudo mkdir /home/code
fi

sudo rm -rf /home/code/*
sudo cp -rvf * /home/code/
```

#### Step - 5 - Job-2 -this job run if job1 build successfully -it will check code, run respective container(PHP or HTML), please find the below code, refer these snaps - (Job-2-snap-1, Job-2-snap-2, Github php code, PHP code running, Github html code, HTML code running).

```
if sudo ls /home/code/ | grep .php
then
	if sudo kubectl get deployment | grep phpos-deploy
	then
		echo "Deployment is already running"
		sudo kubectl apply -f phpos.yml
		sudo kubectl cp /home/code/*.php phpos-pod:/var/www/html/
    else
		echo "No Deployment is running"
        sudo kubectl create -f phpos.yml
        sudo kubectl cp /home/code/*.php phpos-pod:/var/www/html/
    fi
else
	echo "No PHP code is available"
fi

if sudo ls /home/code/ | grep .html
then
	if sudo kubectl get deployment | grep html-deploy
	then
		echo "Deployment is already running"
		sudo kubectl apply -f htmlos.yml
		sudo kubectl cp /home/code/*.html htmlos-pod:/var/www/html/
	else
		echo "No Deployment is running"
        sudo kubectl create -f htmlos.yml
        sudo kubectl cp /home/code/*.html htmlos-pod:/var/www/html/
    fi
else
	echo "No HTML code is available"
fi
```

#### Step - 6 - Job-3 -this job run if job2 build successfully -it will test the code, it is working or not, refer these snaps - (Job-3-snap-1, Job-3-snap-2).

```
if sudo ls /home/code/ | grep index.php
then
	export status=$(curl -o /dev/null -s -w "%{http_code}" http://192.168.99.101:50000/index.php)
	if [ $status -eq 200 ]
	then
		exit 0
	else
		echo "No PHP code found"
		exit 1
	fi
else
	if sudo ls /home/code/ | grep index.html
	then
		export status1=$(curl -o /dev/null -s -w "%{http_code}" http://192.168.99.101:51000/index.html)
		if [ $status1 -eq 200 ]
		then
			exit 0
		else
			echo "No HTML code found"
			exit 1
		fi
	fi
echo "No suitable code found"
exit 1
fi
```

#### Step - 7 - Job-4 -this job run if job3 build unsuccessful -it will send notification to developer, refer these snaps - (job-4, Code error-failed notification).
```
echo "There is a some error in code or no suitable code found, please refer the logs of job3"
exit 1
```

#### Please refer this snap for build pipeline view - (Build pipeline).
