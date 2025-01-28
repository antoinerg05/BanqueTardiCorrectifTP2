
param location string = 'canadacentral'
@secure()
param sqlAdminPassword string

param servicePlans array = [
  {
    name: 'sp-tp2-bt-mvc'
    appServices: [
        {
            name: 'webapp-tp2-bt-mvc'
            MiseAEchelle: 'Auto'
        }
        {
            name: 'webapp-tp2-api-calcul-int'
             MiseAEchelle: 'Non'
        }
    ]
  }
  {
    name: 'sp-tp2-api'
    appServices: [
        {
            name: 'webapp-tp2-api-assurance'
            MiseAEchelle: 'Non'
        }
        {
            name: 'webapp-tp2-api-carte-credit'
            MiseAEchelle : 'Manuel'
        }
    ]
  }
]

param SqlServer array = [
  {
    name: 'srv-sql-tp2-server'
    sqlAdminUser: 'adminuser'
    dbs: [
        {
            name: 'db-tp2-bt-mvc'
        }
        {
            name: 'db-tp2-assurance'
        }
        {
            name: 'db-tp2-carte-credit'
        }
    ]
  }
]



// Module App Service
module appService './modules/appservice.bicep'  = [for (servicePlan, index) in servicePlans: {
  name: '${index}-deployAppService'
  params: {
    location: location
    appServicePlanName: servicePlan.name
    appServices: servicePlan.appservices
  }
}]

// Module SQL
module sql './modules/sql.bicep'  = [for (sqlServer, index) in SqlServer: {
  name: '${index}-deploySqlService'
  params: {
    location: location
    sqlServerName: sqlServer.name
    sqlAdminUser: sqlServer.sqlAdminUser
    sqlAdminPassword: sqlAdminPassword
    dbs: sqlServer.dbs
  }
}]

// Noms des ressources
var storageAccountName = 'sttp2storage'


// Module Storage
module storage './modules/storage.bicep' = {
  name: 'deployStorage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

// Sorties
//output appServicePlanMvc string = appServicePlanMvcName
//output appServicePlanApi string = appServicePlanApiName
//output mvcAppUrl string = appService.outputs.mvcAppUrl
//output apiAppUrl string = appService.outputs.apiAppUrl
//output sqlServer string = sqlServerName
//output sqlDbMvc string = sqlDbMvcName
//output sqlDbApi string = sqlDbApiName
//output storageAccount string = storageAccountName
//output storageContainerUrl string = storage.outputs.containerUrl
