create database ecommerce;
use ecommerce;

create table clients(
    idClient int auto_increment primary key,
    Fname varchar(15),
    Minit char(3),
    Lname varchar(20),
    CPF char(11) not null,
    Adress varchar(30),
    constraint unique_cpf_client unique (CPF)
);

create table product(
    idProduct int auto_increment primary key,
    Pname varchar(15) not null,
    Classification_kids bool default false,
    Category enum('Eletrônico', 'Vestimenta', 'Brinquedos', 'Alimento', 'Móveis') not null,
    Rating float default 0,
    Size varchar(10)
);

create table payment(
    idPayment int auto_increment primary key,
    idClient int,
    typePayment enum('Boleto', 'Cartão', 'Dois Cartões', 'Pix'),
    limitAvailable float,
    constraint fk_payment_client foreign key (idClient) references clients(idClient)
);

create table orders(
    idOrder int auto_increment primary key,
    idOrderClient int,
    orderStatus enum('Cancelado', 'Confirmado', 'Em processamento') default 'Em processamento',
    orderDescription varchar(255),
    shippingFee float default 10,
    paymentCash bool default false,
    idPayment int,
    constraint fk_orders_client foreign key (idOrderClient) references clients(idClient),
    constraint fk_orders_payment foreign key (idPayment) references payment(idPayment)
		on update cascade
        on delete set null
);

create table productStorage (
    idProdStorage int auto_increment primary key,
    storageLocation varchar(255),
    Quantity int default 0
);

create table supplier(
    idSupplier int auto_increment primary key,
    socialName varchar(255) not null,
    CNPJ char(15) not null,
    contact char(11) not null,
    constraint unique_supplier unique (CNPJ)
);

create table seller(
    idSeller int auto_increment primary key,
    socialName varchar(255) not null,
    abstName varchar(255),
    Location varchar(255),
    CNPJ char(15),
    CPF char(9),
    contact char(11) not null,
    constraint unique_cnpj_seller unique (CNPJ),
    constraint unique_cpf_seller unique (CPF)
);

create table productSeller(
    idPseller int,
    idPproduct int,
    prodQuantity int default 1,
    primary key (idPseller, idPproduct),
    constraint fk_product_seller foreign key (idPseller) references seller(idSeller),
    constraint fk_product_product foreign key (idPproduct) references product(idProduct)
);

create table productOrder(
    idPOproduct int,
    idPOorder int,
    poQuantity int default 1,
    poStatus enum('Disponível', 'Sem Estoque') default 'Disponível',
    primary key (idPOproduct, idPOorder),
    constraint fk_product_order_product foreign key (idPOproduct) references product(idProduct),
    constraint fk_product_order_order foreign key (idPOorder) references orders(idOrder)
);

-- Inserindo dados fictícios nas tabelas

insert into clients (Fname, Minit, Lname, CPF, Adress) values
('Joao', 'A', 'Silva', '12345678901', 'Rua das Flores, 123'),
('Maria', 'B', 'Oliveira', '98765432109', 'Avenida Central, 456'),
('Carlos', 'C', 'Santos', '45678912300', 'Praça da Paz, 789');

insert into product (Pname, Classification_kids, Category, Rating, Size) values
('Smartphone', false, 'Eletrônico', 4.5, 'M'),
('Camiseta', false, 'Vestimenta', 4.0, 'G'),
('Boneca', true, 'Brinquedos', 4.8, 'P');

insert into payment (idClient, typePayment, limitAvailable) values
(1, 'Pix', 500.00),
(2, 'Cartão', 1500.00),
(3, 'Boleto', 200.00);

insert into orders (idOrderClient, orderStatus, orderDescription, shippingFee, paymentCash, idPayment) values
(1, 'Confirmado', 'Compra de Smartphone', 15.00, false, 1),
(2, 'Em processamento', 'Compra de Camiseta', 10.00, true, 2);

-- Tabela supplier
insert into supplier (socialName, CNPJ, contact) values
('Fornecedor A', '12345678000190', '11999999999'),
('Fornecedor B', '98765432000100', '21988888888');

insert into seller (socialName, abstName, Location, CNPJ, CPF, contact) values
('Loja A', 'Loja A LTDA', 'Rua Comercial, 100', '12345000111', '123456789', '31977777777'),
('Loja B', 'Loja B EPP', 'Avenida Empresarial, 200', '98765000122', '987654321', '41966666666');

insert into productSeller (idPseller, idPproduct, prodQuantity) values
(1, 1, 50),
(2, 2, 30);

insert into productStorage (storageLocation, Quantity) values
('Depósito Central', 100),
('Loja Filial 1', 50);

insert into productOrder (idPOproduct, idPOorder, poQuantity, poStatus) values
(1, 1, 1, 'Disponível'),
(2, 2, 2, 'Sem Estoque');

-- Queries 

select * from clients;
select Fname, Lname, CPF from clients where CPF = '12345678901';

select * from product where Category = 'Brinquedos';
select * from orders where orderStatus = 'Confirmado';

select Pname, Rating, Rating * 10 as RatingPercent from product;
select idOrder, shippingFee, shippingFee * 1.15 as TotalWithTax from orders;

select * from product order by Rating desc;
select * from clients order by Fname asc;

select Category, avg(Rating) as AvgRating from product group by Category having AvgRating > 4.0;
select idOrderClient, count(*) as TotalOrders from orders group by idOrderClient having TotalOrders > 1;

select c.Fname, c.Lname, o.orderDescription, p.typePayment
from clients c
join orders o on c.idClient = o.idOrderClient
join payment p on o.idPayment = p.idPayment;

select ps.socialName, pr.Pname, pseller.prodQuantity
from seller ps
join productSeller pseller on ps.idSeller = pseller.idPseller
join product pr on pseller.idPproduct = pr.idProduct;
