param location string
param sqlServerName string
param dbs array
param sqlAdminUser string
@secure()
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPassword
  }
}

// D�finition d'un pool �lastique pour les bases de donn�es
resource sqlElasticPool 'Microsoft.Sql/servers/elasticPools@2022-05-01-preview' = {
  parent: sqlServer
  name: 'pool-db1'
  location: location
  sku: {
    name: 'StandardPool'
    tier: 'Standard'
    capacity: 300
  }
  properties: {
    perDatabaseSettings: {
      minCapacity: 50
      maxCapacity: 100
    }
  }
}

// Cr�ation des bases de donn�es dans le pool
resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = [for (db, index) in dbs: {
  parent: sqlServer
  name: db.name
  location: location
  properties: {
    elasticPoolId: sqlElasticPool.id
  }
}]

// Ajout des r�gles de pare-feu pour autoriser des plages d'IP sp�cifiques
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowSpecificIPRange'
  properties: {
    startIpAddress: '100.0.0.1' // D�but de la plage IP
    endIpAddress: '100.10.255.255' // Fin de la plage IP
  }
}
