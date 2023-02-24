# Chatapp



Basic Chatapp, create and use simple chatrooms via 5 pin Code.

It is desired to run on the AWS Cloud infrastructur on a high avaiable EKS Cluster.

### Used technologies:

- Flutter 					→ Frontend
- Expressjs 			→ Middleend
- MySQL (RDS) 	→ Database/Backend
- Docker 				→ Containerization
- AWS 						→ Cloud infrastructur
- Terraform 			→ Infrastructur as Code

**Diagram**:

![](https://slabstatic.com/prod/uploads/8q5jdj6q/posts/images/MbbvMdIWtnYUGp-GazGy4A1p.png)

### Deployment:

These instructions only work with the AWS infrastructur. You also need the AWS Cli Tool, aswell as the Terraform and Kubctl Tool.

Init Terraform provider:

```
terraform init

```

Plan Terraform Script:

```
terraform plan

```

Execute Terraform Script:

```
terraform apply

```

Now you can enter the **Database** and execute the **SQLconstructor** from the **sqlimport** directory on the **Database**.

After the cluster is initialized, you can deploy the Containers to it:

```
kubectl apply -f .\deployment.yaml

```

Additional you can now create a CloudFront instance and add your custom Domain to the Loadbalancers DNS name.
