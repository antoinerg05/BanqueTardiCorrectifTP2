using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BanqueTardi.MVC.Migrations
{
    /// <inheritdoc />
    public partial class Initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Banques",
                columns: table => new
                {
                    ID = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Nom = table.Column<string>(type: "TEXT", nullable: false),
                    TransitID = table.Column<int>(type: "INTEGER", maxLength: 5, nullable: false),
                    InstitutionID = table.Column<int>(type: "INTEGER", maxLength: 3, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Banques", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Clients",
                columns: table => new
                {
                    ID = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Nom = table.Column<string>(type: "TEXT", maxLength: 150, nullable: false),
                    Prenom = table.Column<string>(type: "TEXT", maxLength: 150, nullable: false),
                    DateNaissance = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Adresse = table.Column<string>(type: "TEXT", maxLength: 150, nullable: false),
                    CodePostale = table.Column<string>(type: "TEXT", nullable: false),
                    NbDecouverts = table.Column<int>(type: "INTEGER", nullable: false),
                    Telephone = table.Column<string>(type: "TEXT", nullable: true),
                    NomParent = table.Column<string>(type: "TEXT", nullable: true),
                    TelephoneParent = table.Column<string>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Clients", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "TypeComptes",
                columns: table => new
                {
                    Identifiant = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Libelle = table.Column<string>(type: "TEXT", nullable: false),
                    TauxInteret = table.Column<int>(type: "INTEGER", nullable: false),
                    TauxInteretDecouvert = table.Column<int>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TypeComptes", x => x.Identifiant);
                });

            migrationBuilder.CreateTable(
                name: "Comptes",
                columns: table => new
                {
                    TypeCompteID = table.Column<int>(type: "INTEGER", nullable: false),
                    CompteId = table.Column<int>(type: "INTEGER", nullable: false),
                    BanqueId = table.Column<int>(type: "INTEGER", nullable: false),
                    ClientId = table.Column<int>(type: "INTEGER", nullable: false),
                    Solde = table.Column<decimal>(type: "money", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Comptes", x => new { x.CompteId, x.TypeCompteID });
                    table.ForeignKey(
                        name: "FK_Comptes_Banques_BanqueId",
                        column: x => x.BanqueId,
                        principalTable: "Banques",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Comptes_Clients_ClientId",
                        column: x => x.ClientId,
                        principalTable: "Clients",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Comptes_TypeComptes_TypeCompteID",
                        column: x => x.TypeCompteID,
                        principalTable: "TypeComptes",
                        principalColumn: "Identifiant",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Operations",
                columns: table => new
                {
                    OperationId = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    TypeCompteID = table.Column<int>(type: "INTEGER", nullable: false),
                    CompteId = table.Column<int>(type: "INTEGER", nullable: false),
                    DateOperation = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Montant = table.Column<decimal>(type: "TEXT", nullable: false),
                    Libelle = table.Column<string>(type: "TEXT", nullable: false),
                    TypeOperation = table.Column<string>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Operations", x => x.OperationId);
                    table.ForeignKey(
                        name: "FK_Operations_Comptes_CompteId_TypeCompteID",
                        columns: x => new { x.CompteId, x.TypeCompteID },
                        principalTable: "Comptes",
                        principalColumns: new[] { "CompteId", "TypeCompteID" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Comptes_BanqueId",
                table: "Comptes",
                column: "BanqueId");

            migrationBuilder.CreateIndex(
                name: "IX_Comptes_ClientId",
                table: "Comptes",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_Comptes_TypeCompteID",
                table: "Comptes",
                column: "TypeCompteID");

            migrationBuilder.CreateIndex(
                name: "IX_Operations_CompteId_TypeCompteID",
                table: "Operations",
                columns: new[] { "CompteId", "TypeCompteID" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Operations");

            migrationBuilder.DropTable(
                name: "Comptes");

            migrationBuilder.DropTable(
                name: "Banques");

            migrationBuilder.DropTable(
                name: "Clients");

            migrationBuilder.DropTable(
                name: "TypeComptes");
        }
    }
}
