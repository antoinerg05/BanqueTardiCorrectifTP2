using BanqueTardi.Models;
using BanqueTardi.MVC.Interface;

namespace BanqueTardi.MVC.Services
{
    public class CalculInteretServiceProxy : ICalculInteretService
    {
        private readonly HttpClient _httpClient;

        private const string _calculInteretApiUrl = "api/calculCredit/";

        public CalculInteretServiceProxy(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

      
        public async Task<List<Interet>> Calculer(List<Interet> interets)
        {
            var response = await _httpClient.PostAsJsonAsync(_calculInteretApiUrl, interets);

            response.EnsureSuccessStatusCode();

            return await response.Content.ReadFromJsonAsync<List<Interet>>();
        }
    }
}
