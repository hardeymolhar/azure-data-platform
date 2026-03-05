#resource "random_integer" "suffix" {
#  min = 10000
#  max = 99999
#}
#
##resource "azurerm_redis_cache" "cache" {
# # name                = "cache${random_integer.suffix.result}"
#  #location            = var.location
#  #resource_group_name = var.rg[0]
#  #capacity            = 0
#  #family              = "C"
#  #sku_name            = "Basic"
##}
#
#resource "azurerm_service_plan" "plan" {
#  name                = "myWebAppPlan"
#  location            = var.location
#  resource_group_name = var.rg[0]
#
#  sku_name = "B1"      # match your pricing tier
#  os_type  = "Linux"   # or "Windows"
#}
#
#
#resource "azurerm_app_service" "web" {
#  name                = "webapp${random_integer.suffix.result}"
#  location            = var.location
#  resource_group_name = var.rg[0]
#  app_service_plan_id = azurerm_service_plan.plan.id   # <-- corrected
#
#  #app_settings = {
#  #  "CacheConnection" = "${azurerm_redis_cache.cache.hostname}:6380,password=${azurerm_redis_cache.cache.primary_access_key},ssl=True,abortConnect=False"
#  #}
#}