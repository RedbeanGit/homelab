# Redbean Homelab

This repository contains the configuration files and scripts for my personal homelab setup.

Here are the main components (to be updated):

- **k0s**: Kubernetes distribution for managing containerized applications.
- **Flux**: GitOps tool for continuous deployment.

## Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Command-line tool for interacting with Kubernetes clusters.
- [k0sctl](https://docs.k0sproject.io/stable/install/) - Command-line tool for managing k0s clusters.
- [flux CLI](https://fluxcd.io/docs/installation/) - Command-line tool for managing GitOps with Flux.
- SSH access to your servers.

## How to deploy

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

7. Setup Flux in the cluster:

   ```bash
   # 1. Install Flux namespace, operator and CRDs
   kubectl apply -f flux/infrastructure/flux-system/bootstrap.yaml
   # 2. Create a GitHub deploy key and add it to your repository (you must add it to your Github repo as a deploy key with read access)
   flux create secret git flux-system
   # 3. Start synchronizing the cluster with the repository
   kubectl apply -f flux/clusters/homelab/sync.yaml
   ```

8. Done! Flux will now synchronize the cluster state with the configuration files in this repository.
