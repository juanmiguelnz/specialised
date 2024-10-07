terraform {
    cloud {
        organization = "spendv"
        workspaces {
          name = "web-network-dev"
        }
    }
}