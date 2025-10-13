# Redbean Homelab

This repository contains the configuration files and scripts for my personal homelab setup.

Here are the main components (to be updated):

- **k0s**: Kubernetes distribution for managing containerized applications.

## Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Command-line tool for interacting with Kubernetes clusters.
- [k0sctl](https://docs.k0sproject.io/stable/install/) - Command-line tool for managing k0s clusters.
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
