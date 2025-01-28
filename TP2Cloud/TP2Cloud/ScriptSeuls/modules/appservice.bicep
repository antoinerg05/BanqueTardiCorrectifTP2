// Paramètres principaux
param location string // Emplacement des ressources Azure
param appServicePlanName string // Nom du plan de service App Service
param appServices array // Tableau contenant les configurations des applications Web

// Paramètre pour la mise à l'échelle
@allowed([
  'Non' // Pas de mise à l’échelle
  'Manuel' // Mise à l’échelle manuelle
  'Auto' // Mise à l’échelle automatique
])
param MiseAEchelle string // Définit le type de mise à l'échelle souhaitée

// Détermination du SKU (tarif) en fonction du type de mise à l'échelle
var skuName = (MiseAEchelle == 'Non') ? 'F1' : (MiseAEchelle == 'Manuel') ? 'B1' : 'S1' // Nom du SKU
var skuTier = (MiseAEchelle == 'Non') ? 'Free' : (MiseAEchelle == 'Manuel') ? 'Basic' : 'Standard' // Catégorie du SKU

// Ressource pour le plan de service App Service
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName // Nom du plan de service
  location: location // Emplacement géographique
  sku: {
    name: skuName // Nom du SKU
    tier: skuTier // Catégorie du SKU
    capacity: (MiseAEchelle == 'Manuel') ? 2 : 1 // Nombre d'instances (2 pour manuel, 1 par défaut)
  }
  properties: {
    reserved: false // Indique si le plan est réservé pour Linux (false ici pour Windows)
  }
}

// Ressource pour la mise à l'échelle automatique (si activée)
resource autoScaleSettings 'Microsoft.Insights/autoscaleSettings@2022-10-01' = if (MiseAEchelle == 'Auto') {
  name: '${appServicePlanName}-autoscale' // Nom des paramètres de mise à l'échelle
  location: location // Emplacement géographique
  properties: {
    profiles: [
      {
        name: 'Autoscale Profile' // Profil de mise à l'échelle
        capacity: {
          minimum: '1' // Nombre minimum d'instances
          maximum: '3' // Nombre maximum d'instances
          default: '1' // Nombre d'instances par défaut
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage' // Métrique : utilisation du CPU
              metricResourceUri: appServicePlan.id // URI de la ressource surveillée
              operator: 'GreaterThan' // Condition : supérieur à
              threshold: 70 // Seuil : 70%
              timeGrain: 'PT1M' // Période d'échantillonnage : 1 minute
              statistic: 'Average' // Statistique : moyenne
              timeWindow: 'PT5M' // Fenêtre temporelle : 5 minutes
              timeAggregation: 'Average'
            }
            scaleAction: {
              direction: 'Increase' // Action : augmenter
              type: 'ChangeCount' // Type : changer le nombre d'instances
              value: '1' // Augmenter d'une instance
              cooldown: 'PT1M' // Période de refroidissement : 1 minute
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage' // Métrique : utilisation du CPU
              metricResourceUri: appServicePlan.id // URI de la ressource surveillée
              operator: 'LessThan' // Condition : inférieur à
              threshold: 30 // Seuil : 30%
              timeGrain: 'PT1M' // Période d'échantillonnage : 1 minute
              statistic: 'Average' // Statistique : moyenne
              timeWindow: 'PT5M' // Fenêtre temporelle : 5 minutes
              timeAggregation: 'Average'
            }
            scaleAction: {
              direction: 'Decrease' // Action : diminuer
              type: 'ChangeCount' // Type : changer le nombre d'instances
              value: '1' // Réduire d'une instance
              cooldown: 'PT1M' // Période de refroidissement : 1 minute
            }
          }
        ]
      }
    ]
    enabled: true // Activation des paramètres de mise à l'échelle
    targetResourceUri: appServicePlan.id // URI cible pour l'application de la mise à l'échelle
  }
}

// Ressources pour les applications Web associées au plan de service
resource appServiceApp 'Microsoft.Web/sites@2021-02-01' = [for (appService, index) in appServices: {
  name: '${appService.name}-${substring(uniqueString(appService.name),0,5)}' // Nom unique pour chaque application
  location: location // Emplacement géographique
  properties: {
    serverFarmId: appServicePlan.id // ID du plan de service auquel l'application est associée
  }
}]
