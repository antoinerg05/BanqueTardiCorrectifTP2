// Param�tres principaux
param location string // Emplacement des ressources Azure
param appServicePlanName string // Nom du plan de service App Service
param appServices array // Tableau contenant les configurations des applications Web

// Param�tre pour la mise � l'�chelle
@allowed([
  'Non' // Pas de mise � l��chelle
  'Manuel' // Mise � l��chelle manuelle
  'Auto' // Mise � l��chelle automatique
])
param MiseAEchelle string // D�finit le type de mise � l'�chelle souhait�e

// D�termination du SKU (tarif) en fonction du type de mise � l'�chelle
var skuName = (MiseAEchelle == 'Non') ? 'F1' : (MiseAEchelle == 'Manuel') ? 'B1' : 'S1' // Nom du SKU
var skuTier = (MiseAEchelle == 'Non') ? 'Free' : (MiseAEchelle == 'Manuel') ? 'Basic' : 'Standard' // Cat�gorie du SKU

// Ressource pour le plan de service App Service
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName // Nom du plan de service
  location: location // Emplacement g�ographique
  sku: {
    name: skuName // Nom du SKU
    tier: skuTier // Cat�gorie du SKU
    capacity: (MiseAEchelle == 'Manuel') ? 2 : 1 // Nombre d'instances (2 pour manuel, 1 par d�faut)
  }
  properties: {
    reserved: false // Indique si le plan est r�serv� pour Linux (false ici pour Windows)
  }
}

// Ressource pour la mise � l'�chelle automatique (si activ�e)
resource autoScaleSettings 'Microsoft.Insights/autoscaleSettings@2022-10-01' = if (MiseAEchelle == 'Auto') {
  name: '${appServicePlanName}-autoscale' // Nom des param�tres de mise � l'�chelle
  location: location // Emplacement g�ographique
  properties: {
    profiles: [
      {
        name: 'Autoscale Profile' // Profil de mise � l'�chelle
        capacity: {
          minimum: '1' // Nombre minimum d'instances
          maximum: '3' // Nombre maximum d'instances
          default: '1' // Nombre d'instances par d�faut
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage' // M�trique : utilisation du CPU
              metricResourceUri: appServicePlan.id // URI de la ressource surveill�e
              operator: 'GreaterThan' // Condition : sup�rieur �
              threshold: 70 // Seuil : 70%
              timeGrain: 'PT1M' // P�riode d'�chantillonnage : 1 minute
              statistic: 'Average' // Statistique : moyenne
              timeWindow: 'PT5M' // Fen�tre temporelle : 5 minutes
              timeAggregation: 'Average'
            }
            scaleAction: {
              direction: 'Increase' // Action : augmenter
              type: 'ChangeCount' // Type : changer le nombre d'instances
              value: '1' // Augmenter d'une instance
              cooldown: 'PT1M' // P�riode de refroidissement : 1 minute
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage' // M�trique : utilisation du CPU
              metricResourceUri: appServicePlan.id // URI de la ressource surveill�e
              operator: 'LessThan' // Condition : inf�rieur �
              threshold: 30 // Seuil : 30%
              timeGrain: 'PT1M' // P�riode d'�chantillonnage : 1 minute
              statistic: 'Average' // Statistique : moyenne
              timeWindow: 'PT5M' // Fen�tre temporelle : 5 minutes
              timeAggregation: 'Average'
            }
            scaleAction: {
              direction: 'Decrease' // Action : diminuer
              type: 'ChangeCount' // Type : changer le nombre d'instances
              value: '1' // R�duire d'une instance
              cooldown: 'PT1M' // P�riode de refroidissement : 1 minute
            }
          }
        ]
      }
    ]
    enabled: true // Activation des param�tres de mise � l'�chelle
    targetResourceUri: appServicePlan.id // URI cible pour l'application de la mise � l'�chelle
  }
}

// Ressources pour les applications Web associ�es au plan de service
resource appServiceApp 'Microsoft.Web/sites@2021-02-01' = [for (appService, index) in appServices: {
  name: '${appService.name}-${substring(uniqueString(appService.name),0,5)}' // Nom unique pour chaque application
  location: location // Emplacement g�ographique
  properties: {
    serverFarmId: appServicePlan.id // ID du plan de service auquel l'application est associ�e
  }
}]
