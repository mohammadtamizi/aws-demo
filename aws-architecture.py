from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import ECS, ECR, Fargate
from diagrams.aws.network import ELB, VPC, InternetGateway, PublicSubnet, PrivateSubnet
from diagrams.aws.security import IAM
from diagrams.aws.management import Cloudwatch
from diagrams.aws.storage import S3
from diagrams.onprem.vcs import Github
from diagrams.onprem.client import User
from diagrams.onprem.container import Docker
from diagrams.programming.language import Javascript
from diagrams.onprem.iac import Terraform  # Only if available
from diagrams.custom import Custom

graph_attr = {
    "fontsize": "28",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "ortho",
    "nodesep": "0.15",
    "ranksep": "0.3"
}

with Diagram("AWS Containerized Website Deployment", show=True, direction="LR", graph_attr=graph_attr):
    # Local development
    with Cluster("Local Development"):
        local_app = Javascript("Next.js Web App")
        docker_container = Docker("Docker Container")

    # GitHub and CI/CD
    with Cluster("GitHub & CI/CD"):
        github = Github("GitHub Repository")
        github_actions = Custom("GitHub Actions (CI/CD)", "./github-actions.png")
        terraform = Terraform("Terraform")  # If diagrams.onprem.iac.Terraform is available

    user = User("User")

    with Cluster("AWS Cloud"):
        lb = ELB("Load Balancer")
        cloudwatch = Cloudwatch("CloudWatch")
        image_repo = ECR("Amazon ECR")
        tf_state = S3("S3 (Terraform State)")

        with Cluster("VPC"):
            igw = InternetGateway("Internet Gateway")
            subnet_pub = PublicSubnet("Public Subnet")
            subnet_priv = PrivateSubnet("Private Subnet")

            with Cluster("ECS Cluster"):
                ecs_service = ECS("ECS Service")
                fargate_task = Fargate("Fargate Task\n(Web App)")

        iam = IAM("IAM Roles")

    user >> Edge(label="HTTPS\n(SSL Termination)", color="black") >> lb
    local_app - Edge(color="black") - docker_container
    docker_container >> Edge(label="Push", color="blue") >> github

    # GitHub repo to Terraform (code is stored here)
    github >> Edge(label="IaC Code", style="dotted", color="purple") >> terraform
    terraform >> Edge(label="Apply Infra", color="purple", style="dashed") >> tf_state

    github >> Edge(label="Trigger CI/CD", color="blue") >> github_actions

    github_actions >> Edge(label="Build & Push Image", color="blue") >> image_repo
    #github_actions >> Edge(label="Deploy App", color="blue", style="dashed") >> ecs_service

    igw - Edge(color="black") - subnet_pub
    lb >> Edge(label="Forward Traffic", color="darkgreen") >> subnet_pub
    subnet_priv >> Edge(color="darkgreen") >> ecs_service
    ecs_service >> fargate_task
    image_repo >> Edge(label="Pull Image", color="darkgreen", style="dashed") >> ecs_service
    iam - Edge(label="Task Execution Role", style="dotted") - ecs_service
    iam - Edge(label="Task Role", style="dotted") - fargate_task
    fargate_task >> Edge(label="Logs", color="red", style="dotted") >> cloudwatch
    lb >> Edge(label="Metrics", color="red", style="dotted") >> cloudwatch
