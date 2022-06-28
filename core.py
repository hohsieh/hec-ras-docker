import os
import sys
import configparser

# read config file
config_file = "/project/config.ini"

# ----------------------------------------------------------------------------------------------------------------------
## Definations

# confirm file exists
def check_file(file):
    if not os.path.isfile(file):
        print('Config file not found!')
        sys.exit(1)
    else:
        return file

# ----------------------------------------------------------------------------------------------------------------------
## Optional S3 configuration

#aws_access_key=""
#aws_secret_key=""
#s3_bucket_name=""

# save the aws config
#def save_aws_config(aws_access_key, aws_secret_key):
#    if aws_access_key and aws_secret_key:
#        with open('/root/.passwd.s3fs', 'w') as f:
#            f.write(aws_access_key + '\n')
#            f.write(aws_secret_key)
#    else:
#        print('AWS config not set')
#        sys.exit(1)

# mount the s3 bucket
#def mount_s3_bucket(s3_bucket_name):
#    if s3_bucket_name:
#        os.system('s3fs ' + s3_bucket_name +'/project -o passwd_file=/root/.passwd-s3fs -o allow_other -o use_cache=/tmp -o umask=0000')
#        os.system('s3fs ' + s3_bucket_name +'/results -o passwd_file=/root/.passwd-s3fs -o allow_other -o use_cache=/tmp -o umask=0000')
#    else:
#        print('S3 bucket not set')
#        sys.exit(1)


# save config and mount bucket
#save_aws_config(aws_access_key, aws_secret_key)
#mount_s3_bucket(s3_bucket_name)

# ----------------------------------------------------------------------------------------------------------------------
## Configure the environment

# load config file
config = configparser.ConfigParser()
config.read(check_file(config_file))

# set the thread limit
try:
    thread_max = config.get('hardware', 'thread_max')
except:
    thread_max = os.cpu_count()

# set the memory limit
try:
    memory_max = config.get('hardware', 'memory_max')
except:
    memory_max = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')

# set the project name
try:
    project_name = config.get('project', 'name')
except:
    project_name = "MyProject"



# set MKL_DOMAIN_PARDISO to thread_max
os.environ['MKL_DOMAIN_PARDISO'] = str(thread_max)
# set MKL_DOMAIN_BLAS to thread_max
os.environ['MKL_DOMAIN_BLAS'] = str(thread_max)
# set MKL_BLAS to thread_max
os.environ['MKL_BLAS'] = str(thread_max)
# set OMP_NUM_THREADS to thread_max
os.environ['OMP_NUM_THREADS'] = str(thread_max)
# set OMP_THREAD_LIMIT to thread_max
os.environ['OMP_THREAD_LIMIT'] = str(thread_max)
# set OMP_STACKSIZE to memory_max
os.environ['OMP_STACKSIZE'] = str(memory_max)
# set OMP_PROC_BIND to 'true'
os.environ['OMP_PROC_BIND'] = 'true'
# set OMP_DYNAMIC to 'false'
os.environ['OMP_DYNAMIC'] = 'false'
# set MKL_SERIAL to 'OMP'
os.environ['MKL_SERIAL'] = 'OMP'

# rsync /project/ to /hecras/project
print('Syncing project data to local container environment, this may take a while...')
os.system('rsync -a /project/ /hecras/project')

# create /results/project/results directory
os.system('mkdir -p /hecras/project/results')

# symlink /results to /hecras/project/results
os.system('ln -s /results/ /hecras/project/results')

# print project name, thread_max and memory_max
print('Project name: ' + project_name)
print('Configured Threads: ' + str(thread_max))
print('Configured Memory: ' + str(memory_max))

# ----------------------------------------------------------------------------------------------------------------------
## Run the project

# change to the project directory
os.chdir('/hecras/project')

# confirm execute permissions on project bash script
os.system('chmod +x /hecras/project/' + project_name + '.sh')

# run the project bash script
os.system('/hecras/project/'+ project_name +'.sh')