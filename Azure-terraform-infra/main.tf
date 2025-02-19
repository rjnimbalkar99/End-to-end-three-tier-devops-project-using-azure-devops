#Create a resource group
resource "azurerm_resource_group" "Devops_project-2" {
    name = var.resource_group_name
    location = "Centralindia"   
}

#Create Virtual network
resource "azurerm_virtual_network" "Vnet-1" {
    name = var.virtual_network_name
    resource_group_name = var.resource_group_name
    location = "Centralindia"
    address_space = [ "10.1.0.0/16" ]  
    depends_on = [ azurerm_resource_group.Devops_project-2 ]
}

#Create a subnet-1
resource "azurerm_subnet" "Subnet-1" {
    name = "Subnet-1"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.Vnet-1.name
    address_prefixes = [ "10.1.1.0/24" ]
    depends_on = [ azurerm_virtual_network.Vnet-1 ]
}

#Create a subnet-2
resource "azurerm_subnet" "Subnet-2" {
    name = "Subnet-2"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.Vnet-1.name
    address_prefixes = [ "10.1.2.0/24" ]
    depends_on = [ azurerm_virtual_network.Vnet-1 ]
}

#Create Azure container registory for backend.
resource "azurerm_container_registry" "ACR-1" {
  name = "azureimageregistory-backend"
  resource_group_name = var.resource_group_name
  location = "Centralindia"
  sku = "Standard"
  depends_on = [ azurerm_resource_group.Devops_project-2 ]
}

#Create Azure container registory for frontend.
resource "azurerm_container_registry" "ACR-2" {
  name = "azureimageregistory-frontend"
  resource_group_name = var.resource_group_name
  location = "Centralindia"
  sku = "Standard"
  depends_on = [ azurerm_resource_group.Devops_project-2 ]
}

#Create AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "Three-tier-application"
  kubernetes_version  = "1.30.6"
  location            = "Centralindia"
  resource_group_name = var.resource_group_name
  dns_prefix          = "Three-tier-application"
  depends_on = [ azurerm_subnet_network_security_group_association.nsg-associ ]

  default_node_pool {
    name                = "system"
    node_count          = "2"
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.Subnet-2.id
    type                = "VirtualMachineScaleSets"
    zones  = [1, 2, 3]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }
}

#Assign role to AKS cluster for accessing the ACR-1
resource "azurerm_role_assignment" "managed-identity" {
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.ACR-1.id
  principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

#Assign role to AKS cluster for accessing the ACR-2
resource "azurerm_role_assignment" "managed-identity" {
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.ACR-2.id
  principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

#Create Network Security Group 
resource "azurerm_network_security_group" "nsg" {
  name = "NSG"
  resource_group_name = var.resource_group_name
  location = "Centralindia"
  depends_on = [ azurerm_subnet.Subnet-1 , azurerm_resource_group.Devops_project-2 ]
  
  security_rule {

    name = "Inbound-80"
    priority = "100"
    access = "Allow"
    direction = "Inbound"
    protocol = "Tcp"
    source_address_prefix = "*" 
    destination_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "80"
  }

  security_rule {
    name = "Allow_Inbound-443"
    priority = "110"
    access = "Allow"
    direction = "Inbound"
    protocol = "Tcp"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "443"
  }

  security_rule {
    name = "Allow_Inbound-3000"
    priority = "120"
    access = "Allow"
    direction = "Inbound"
    protocol = "Tcp"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "3000"
  }
}

#Associate the NSG to subnet-1
resource "azurerm_subnet_network_security_group_association" "nsg-associ" {
  subnet_id = azurerm_subnet.Subnet-1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#Associate the NSG to subnet-2 
resource "azurerm_subnet_network_security_group_association" "nsg-associ" {
  subnet_id = azurerm_subnet.Subnet-2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
