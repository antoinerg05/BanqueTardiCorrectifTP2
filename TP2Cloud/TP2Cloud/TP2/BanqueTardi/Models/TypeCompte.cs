using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace BanqueTardi.Models
{
    public class TypeCompte
    {

        [Key]
        public int Identifiant { get; set; }
        
        public string Libelle { get; set; }

        public int TauxInteret { get; set; }

        public int TauxInteretDecouvert { get; set; }

        public TypeCompte(int identifiant, string libelle, int tauxInteret, int tauxInteretDecouvert)
        {
            Identifiant = identifiant;
            Libelle = libelle;
            TauxInteret = tauxInteret;
            TauxInteretDecouvert = tauxInteretDecouvert;
        }
    }
}
