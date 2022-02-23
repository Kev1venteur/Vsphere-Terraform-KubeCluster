# Vsphere-Terraform-KubeCluster
:key: Ce repo fournit les fichiers Packer, Terraform et Ansible pour dépoyer sur VSphere une partie de l'infrastructure illustrée ci-dessous (voir le Déroulé plus bas) : 

<p align="center">
  <img src="annexes/images/SchemaFinal.png?style=centerme"  width="500">
</p>

:information_source: Le playbook ansible n'est pas encore [Idempotent](https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html).<br />
Il faudra entre chaque lancement du playbook Ansible, détruire et reconstruire les 6 noeuds K8s :
```bash
echo "yes" | terraform destroy && echo "yes" | terraform apply
```
C'est un point que nous savons à améliorer, n'hésitez pas à faire des PR !<br />

:information_source: Les mots de passe sont à changer dans ces fichiers :<br />
● Le JSON pour Packer, il faut paramétrer les variables dans [ce fichier](packer/Ubuntu2004-Packer.json).<br />
● Le fichier User-Data pour la VM Packer, mettre le mot de passe User hashé [ici](packer/http/user-data#L20).<br />
Ce mot de passe est à générer avec la commande :
```bash
mkpasswd -m sha-512 "Ton MDP USER"
#mkpasswd est installable avec le package whois
sudo apt-get install whois
```
● Pour Terraform, c'est [ce fichier](terraform/terraform.tfvars) qu'il faut adapter à votre configuration.<br />
● Pour Ansible, c'est [ce fichier](ansible/hosts) qu'il faut adapter à votre configuration.<br />
● Il faut aussi changer les passwords des YAML [Wordpress](ansible/roles/kube-apps/templates/wordpress.yaml#L68) et [MySQL](ansible/roles/kube-apps/templates/mysql.yaml#L66).<br />

## Prérequis
Installez les packages nécessaires.
```bash
#Installation des outils pour récupérer les packages Hashicorp
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl apt-transport-https ca-certificates
#Récupération des cléfs GPG Hashicorp et Google
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#Ajout du repo Hashicorp
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#Installation des packages nécessaires
sudo apt-get update && sudo apt-get install -y packer terraform mkisofs whois ansible sshpass kubectl
```

## Kickstart

```BASH
# Pour commencer, clonez le repo
git clone https://github.com/Kev1venteur/Vsphere-Terraform-KubeCluster.git && cd Vsphere-Terraform-KubeCluster
#Ajoutez les droits d'execution sur le script
chmod +x magik-script.sh 
#Lancez le script
./magik-script.sh
```

## Déroulé

### Etape 1
Exécution de Packer - Build d'un template VSphere à partir d'un ISO Ubuntu 20.04 déjà présent sur le Datastore VSphere.
<p align="center">
  <img src="annexes/images/Schemas1Packer.png?style=centerme" width="500">
</p>

### Etape 2
Exécution de Terraform - Récupération du template pour créer 6 VMs avec les [ressources souhaitées](terraform/terraform.tfvars#L11).
<p align="center">
  <img src="annexes/images/Schema2Terraform.png?style=centerme" width="500">
</p>

### Etape 3
Exécution d'Ansible :<br />
● Installation de Docker et tous les outils K8s sur les 6 VMs<br />
● Création d'un cluster Etcd sur les 3 machines master + leurs mise en keepalive<br />
● Jonction des 3 autres noeud au cluster kube en tant que workers<br />
● Déploiement des pods pour la boutique Wordpress et son stockage en base de données<br />
<p align="center">
  <img src="annexes/images/Schema3Ansible.png?style=centerme" width="500">
</p>

## Résultat

Vous avez un Wordpress lié à une bdd MySQL qui sont en place sur un cluster K8s multi-master en moins de 30 minutes.

## Debug

#### Augmentez le niveau de log de Terraform

Avant de lancer le script définissez les variables d'environnement pour changer vos loglevels.
```bash
#Packer Loglevel
export PACKER_LOG=1
#Terraform Loglevel
export TF_LOG=DEBUG
#Ansible Loglevel
export ANSIBLE_DEBUG=True
```
