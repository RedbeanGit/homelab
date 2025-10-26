# Redbean Homelab

This repository contains the configuration files and scripts for my personal homelab setup.

Here are the main components (to be updated):

- **k0s**: Kubernetes distribution for managing containerized applications.
- **Flux**: GitOps tool for continuous deployment.
- **Sops/Age**: Tools for managing secrets in a secure way.

## Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Command-line tool for interacting with Kubernetes clusters.
- [k0sctl](https://docs.k0sproject.io/stable/install/) - Command-line tool for managing k0s clusters.
- [flux CLI](https://fluxcd.io/docs/installation/) - Command-line tool for managing GitOps with Flux.
- [Sops](https://github.com/mozilla/sops) - Tool for managing secrets using YAML, JSON, and ENV files.
- SSH access to your servers.

## How to deploy

### 1. Cluster Setup with k0s

1. Clone the repository to your local machine:

   ```bash
   git clone git@github.com:RedbeanGit/homelab.git
   cd homelab
   ```

2. Generate or copy your SSH keys to the `k0s/keys` directory under `homelab` name.

3. Edit the `k0s/k0sctl.yaml` file to match your server IP addresses / hostnames (you can also add more nodes).

4. Deploy the k0s cluster using k0sctl:

   ```bash
   k0sctl apply --config k0s/k0sctl.yaml
   ```

5. Gain access to the cluster:

   ```bash
   k0sctl kubeconfig get --config k0s/k0sctl.yaml > kubeconfig
   export KUBECONFIG=$(pwd)/kubeconfig
   ```

6. Verify the cluster is up and running:

   ```bash
   kubectl get nodes
   ```

### 2. Sops Setup

1. Install Sops on your local machine if you haven't already.

2. Create an Age key pair for encrypting/decrypting secrets:

   ```bash
   # Generate a new Age key pair for personal use
   age-keygen -o age-personal.key
   # Generate a new Age key pair for the cluster
   age-keygen -o age-homelab.key
   ```

3. Move the personal age key to the default Sops location for easier access:

   ```bash
   # If it's the first time, create the directory and move the key
   mkdir -p ~/.config/sops/age
   mv age-personal.key ~/.config/sops/age/keys.txt
   # Otherwise, append the new key to the existing keys.txt
   cat age-personal.key >> ~/.config/sops/age/keys.txt
   rm age-personal.key
   ```

4. Add the public keys from `age-personal.key` and `age-homelab.key` to `.sops.yaml` in `creation_rules.age`.

5. Deploy the Sops keys (the one for the cluster) to the cluster:

   ```bash
   # Create the flux-system namespace and add the age key as a secret
   kubectl create namespace flux-system
   kubectl create secret generic sops-age \
      --namespace=flux-system \
      --from-file=age.agekey=age-homelab.key
   # You can now delete the local age-homelab.key file for security
   rm age-homelab.key
   ```

6. Recreate the secret files in `flux/clusters/homelab/cluster-secret-vars.yaml` using Sops:

   ```bash
   # Edit the file to add your secrets (it will be in plaintext) and remove `sops` metadata if present
   # Then encrypt it in place
   sops --encrypt --in-place flux/clusters/homelab/cluster-secret-vars.yaml
   ```

7. Save and commit the changes to the repository.

   ```bash
   git add flux/clusters/homelab/cluster-secret-vars.yaml
   git commit -m "chore: update cluster secret vars"
   git push origin main
   ```

### 3. Flux Setup

1. Install Flux namespace, operator and CRDs:

   ```bash
   kubectl apply -f flux/infrastructure/flux-system/bootstrap.yaml
   ```

2. Create a GitHub deploy key and add it to your repository (you must add it to your Github repo as a deploy key with read access)

   ```bash
   flux create secret git flux-system --url=ssh://git@github.com/RedbeanGit/homelab.git
   ```

3. Start synchronizing the cluster with the repository

   ```bash
   kubectl apply -f flux/clusters/homelab/sync.yaml
   ```

4. Done! Flux will now synchronize the cluster state with the configuration files in this repository.
