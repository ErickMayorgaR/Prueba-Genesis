using Microsoft.EntityFrameworkCore;
using backend_api.Models;

namespace backend_api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    // Catálogo
    public DbSet<Categoria> Categorias => Set<Categoria>();
    public DbSet<Producto> Productos => Set<Producto>();
    public DbSet<Presentacion> Presentaciones => Set<Presentacion>();
    public DbSet<Atributo> Atributos => Set<Atributo>();
    public DbSet<AtributoOpcion> AtributoOpciones => Set<AtributoOpcion>();

    // Combos
    public DbSet<Combo> Combos => Set<Combo>();
    public DbSet<ComboItem> ComboItems => Set<ComboItem>();

    // Inventario
    public DbSet<MateriaPrima> MateriasPrimas => Set<MateriaPrima>();
    public DbSet<InventarioMovimiento> InventarioMovimientos => Set<InventarioMovimiento>();

    // Ventas
    public DbSet<Sucursal> Sucursales => Set<Sucursal>();
    public DbSet<Venta> Ventas => Set<Venta>();
    public DbSet<VentaItem> VentaItems => Set<VentaItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configuración de Categoria
        modelBuilder.Entity<Categoria>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nombre).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Descripcion).HasMaxLength(200);
            entity.Property(e => e.Icono).HasMaxLength(50);
        });

        // Configuración de Producto
        modelBuilder.Entity<Producto>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Codigo).HasMaxLength(20);
            entity.HasIndex(e => e.Codigo).IsUnique();
            entity.Property(e => e.Nombre).HasMaxLength(100).IsRequired();
            entity.Property(e => e.Descripcion).HasMaxLength(500);
            entity.Property(e => e.ImagenUrl).HasMaxLength(300);

            entity.HasOne(e => e.Categoria)
                  .WithMany(c => c.Productos)
                  .HasForeignKey(e => e.CategoriaId);
        });

        // Configuración de Presentacion
        modelBuilder.Entity<Presentacion>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nombre).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Precio).HasPrecision(10, 2);

            entity.HasOne(e => e.Producto)
                  .WithMany(p => p.Presentaciones)
                  .HasForeignKey(e => e.ProductoId);
        });

        // Configuración de Atributo
        modelBuilder.Entity<Atributo>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nombre).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Codigo).HasMaxLength(30).IsRequired();
            entity.HasIndex(e => new { e.CategoriaId, e.Codigo }).IsUnique();

            entity.HasOne(e => e.Categoria)
                  .WithMany(c => c.Atributos)
                  .HasForeignKey(e => e.CategoriaId);
        });

        // Configuración de AtributoOpcion
        modelBuilder.Entity<AtributoOpcion>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nombre).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Codigo).HasMaxLength(30).IsRequired();
            entity.Property(e => e.PrecioExtra).HasPrecision(10, 2);

            entity.HasOne(e => e.Atributo)
                  .WithMany(a => a.Opciones)
                  .HasForeignKey(e => e.AtributoId);
        });

        // Configuración de Combo
        modelBuilder.Entity<Combo>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nombre).HasMaxLength(100).IsRequired();
            entity.Property(e => e.Descripcion).HasMaxLength(500);
            entity.Property(e => e.Precio).HasPrecision(10, 2);
            entity.Property(e => e.Tipo).HasMaxLength(20);
        });

        // Configuración de ComboItem
        modelBuilder.Entity<ComboItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Notas).HasMaxLength(100);

            entity.HasOne(e => e.Combo)
                  .WithMany(c => c.Items)
                  .HasForeignKey(e => e.ComboId);

            entity.HasOne(e => e.Presentacion)
                  .WithMany()
                  .HasForeignKey(e => e.PresentacionId);
        });

        // Configuración de MateriaPrima
        modelBuilder.Entity<MateriaPrima>(entity =>
        {
            entity.ToTable("MateriaPrimas");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Categoria).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Nombre).HasMaxLength(100).IsRequired();
            entity.Property(e => e.UnidadMedida).HasMaxLength(20).IsRequired();
            entity.Property(e => e.StockActual).HasPrecision(10, 2);
            entity.Property(e => e.StockMinimo).HasPrecision(10, 2);
            entity.Property(e => e.PuntoCritico).HasPrecision(10, 2);
            entity.Property(e => e.CostoPromedio).HasPrecision(10, 2);
        });

        // Configuración de InventarioMovimiento
        modelBuilder.Entity<InventarioMovimiento>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Tipo).HasMaxLength(1).IsRequired();
            entity.Property(e => e.Cantidad).HasPrecision(10, 2);
            entity.Property(e => e.CostoUnitario).HasPrecision(10, 2);
            entity.Property(e => e.Motivo).HasMaxLength(200);

            entity.HasOne(e => e.MateriaPrima)
                  .WithMany(m => m.Movimientos)
                  .HasForeignKey(e => e.MateriaPrimaId);
        });

        // Configuración de Sucursal
        modelBuilder.Entity<Sucursal>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nombre).HasMaxLength(100).IsRequired();
            entity.Property(e => e.Direccion).HasMaxLength(200);
            entity.Property(e => e.Telefono).HasMaxLength(20);
        });

        // Configuración de Venta
        modelBuilder.Entity<Venta>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Codigo).HasMaxLength(20);
            entity.Property(e => e.Subtotal).HasPrecision(10, 2);
            entity.Property(e => e.Descuento).HasPrecision(10, 2);
            entity.Property(e => e.Total).HasPrecision(10, 2);
            entity.Property(e => e.Estado).HasMaxLength(20);

            entity.HasOne(e => e.Sucursal)
                  .WithMany(s => s.Ventas)
                  .HasForeignKey(e => e.SucursalId);
        });

        // Configuración de VentaItem
        modelBuilder.Entity<VentaItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.PrecioUnitario).HasPrecision(10, 2);
            entity.Property(e => e.PrecioExtras).HasPrecision(10, 2);
            entity.Property(e => e.Subtotal).HasPrecision(10, 2);

            entity.HasOne(e => e.Venta)
                  .WithMany(v => v.Items)
                  .HasForeignKey(e => e.VentaId);

            entity.HasOne(e => e.Presentacion)
                  .WithMany()
                  .HasForeignKey(e => e.PresentacionId)
                  .IsRequired(false);

            entity.HasOne(e => e.Combo)
                  .WithMany()
                  .HasForeignKey(e => e.ComboId)
                  .IsRequired(false);
        });
    }
}
