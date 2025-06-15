-- DDL - Data Definition Language (CREATE, ALTER, RENAME, DROP)

-- Membuat tabel departemen
CREATE TABLE departemen (
    id_departemen INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nama_departemen VARCHAR(100) NOT NULL
);

-- Membuat tabel jabatan
CREATE TABLE jabatan (
    id_jabatan INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nama_jabatan VARCHAR(100) NOT NULL,
    gaji_pokok INT NOT NULL
);

-- Membuat tabel karyawan
CREATE TABLE karyawan (
    id_karyawan INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nama_karyawan VARCHAR(150) NOT NULL,
    jenis_kelamin CHAR(1),
    tgl_masuk DATE,
    id_departemen INT,
    id_jabatan INT,
    FOREIGN KEY (id_departemen) REFERENCES departemen(id_departemen),
    FOREIGN KEY (id_jabatan) REFERENCES jabatan(id_jabatan)
);

-- Membuat tabel untuk mencatat histori gaji
CREATE TABLE gaji (
    id_gaji INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_karyawan INT,
    tgl_pembayaran DATE,
    bonus INT DEFAULT 0,
    potongan INT DEFAULT 0,
    FOREIGN KEY (id_karyawan) REFERENCES karyawan(id_karyawan)
);



-- DML atau Data Manipulation Language (SELECT, INSERT, UPDATE, DELETE)
-- Mengisi tabel departemen
INSERT INTO departemen (nama_departemen) VALUES
('Teknologi Informasi'), ('Sumber Daya Manusia'), ('Pemasaran');

-- Mengisi tabel jabatan
INSERT INTO jabatan (nama_jabatan, gaji_pokok) VALUES
('IT Manager', 20000000), ('Software Engineer', 12000000), ('UI/UX Designer', 10000000),
('HR Manager', 18000000), ('Recruiter', 9000000),
('Marketing Manager', 17000000), ('Digital Marketer', 8000000);

-- Mengisi tabel karyawan
INSERT INTO karyawan (nama_karyawan, jenis_kelamin, tgl_masuk, id_departemen, id_jabatan) VALUES
('Budi Santoso', 'L', '2020-01-15', 1, 1),    -- IT Manager
('Ani Lestari', 'P', '2021-03-20', 1, 2),     -- Software Engineer
('Charlie Wijaya', 'L', '2022-07-01', 1, 2),  -- Software Engineer
('Dewi Anggraini', 'P', '2021-08-11', 1, 3),  -- UI/UX Designer
('Eko Prasetyo', 'L', '2019-05-10', 2, 4),    -- HR Manager
('Fina Rahmawati', 'P', '2023-01-20', 2, 5),  -- Recruiter
('Gita Permata', 'P', '2020-11-05', 3, 6),    -- Marketing Manager
('Hadi Kurniawan', 'L', '2022-02-18', 3, 7);  -- Digital Marketer

-- Mengisi tabel gaji untuk bulan Juni 2025
INSERT INTO gaji (id_karyawan, tgl_pembayaran, bonus, potongan) VALUES
(1, '2025-06-25', 2000000, 150000),
(2, '2025-06-25', 1000000, 100000),
(3, '2025-06-25', 1000000, 100000),
(4, '2025-06-25', 750000, 50000),
(5, '2025-06-25', 1500000, 120000),
(6, '2025-06-25', 500000, 50000),
(7, '2025-06-25', 1200000, 100000),
(8, '2025-06-25', 400000, 40000);


-- UPDATE
-- Tambahkan jabatan baru
INSERT INTO jabatan (nama_jabatan, gaji_pokok) VALUES ('Senior Software Engineer', 16000000);

-- Update jabatan Ani Lestari
UPDATE karyawan
SET id_jabatan = 8 -- Anggap ID 'Senior Software Engineer' adalah 8
WHERE id_karyawan = 2;


-- STUDY CASE
-- Menghapus data gaji terkait terlebih dahulu untuk menjaga integritas referensial
DELETE FROM gaji WHERE id_karyawan = 8;

-- Menghapus data karyawan
DELETE FROM karyawan WHERE id_karyawan = 8;




-- Data Query Language

-- Analisis Gaji
SELECT
    k.nama_karyawan,
    d.nama_departemen,
    j.nama_jabatan,
    j.gaji_pokok,
    g.bonus,
    g.potongan,
    (j.gaji_pokok + g.bonus - g.potongan) AS gaji_bersih
FROM karyawan k
INNER JOIN departemen d ON k.id_departemen = d.id_departemen
INNER JOIN jabatan j ON k.id_jabatan = j.id_jabatan
INNER JOIN gaji g ON k.id_karyawan = g.id_karyawan;



-- 1. Rata-rata, Gaji Tertinggi, Gaji Terendah, dan Total Gaji Bersih Seluruh Karyawan
SELECT
    AVG(j.gaji_pokok + g.bonus - g.potongan) AS rata_rata_gaji_bersih,
    MAX(j.gaji_pokok + g.bonus - g.potongan) AS gaji_tertinggi,
    MIN(j.gaji_pokok + g.bonus - g.potongan) AS gaji_terendah,
    SUM(j.gaji_pokok + g.bonus - g.potongan) AS total_pengeluaran_gaji,
    COUNT(k.id_karyawan) AS jumlah_karyawan
FROM karyawan k
JOIN jabatan j ON k.id_jabatan = j.id_jabatan
JOIN gaji g ON k.id_karyawan = g.id_karyawan;

-- 2. Rata-rata gaji bersih DIKELOMPOKKAN per departemen
SELECT
    d.nama_departemen,
    AVG(j.gaji_pokok + g.bonus - g.potongan) AS rata_rata_gaji_departemen,
    COUNT(k.id_karyawan) AS jumlah_karyawan_di_departemen
FROM karyawan k
JOIN departemen d ON k.id_departemen = d.id_departemen
JOIN jabatan j ON k.id_jabatan = j.id_jabatan
JOIN gaji g ON k.id_karyawan = g.id_karyawan
GROUP BY d.nama_departemen;



SELECT
    nama_karyawan,
    (j.gaji_pokok + g.bonus - g.potongan) AS gaji_bersih
FROM karyawan k
JOIN jabatan j ON k.id_jabatan = j.id_jabatan
JOIN gaji g ON k.id_karyawan = g.id_karyawan
WHERE (j.gaji_pokok + g.bonus - g.potongan) > (
    SELECT AVG(j2.gaji_pokok + g2.bonus - g2.potongan)
    FROM karyawan k2
    JOIN jabatan j2 ON k2.id_jabatan = j2.id_jabatan
    JOIN gaji g2 ON k2.id_karyawan = g2.id_karyawan
);





WITH GajiKaryawan AS (
    -- Langkah 1: Definisikan tabel sementara 'GajiKaryawan'
    SELECT
        k.nama_karyawan,
        (j.gaji_pokok + g.bonus - g.potongan) AS gaji_bersih
    FROM karyawan k
    JOIN jabatan j ON k.id_jabatan = j.id_jabatan
    JOIN gaji g ON k.id_karyawan = g.id_karyawan
)
-- Langkah 2: Gunakan tabel sementara tersebut untuk kalkulasi akhir
SELECT *
FROM GajiKaryawan
WHERE gaji_bersih > (SELECT AVG(gaji_bersih) FROM GajiKaryawan);




SELECT
    d.nama_departemen,
    AVG(j.gaji_pokok + g.bonus - g.potongan) AS rata_rata_gaji_departemen
FROM karyawan k
JOIN departemen d ON k.id_departemen = d.id_departemen
JOIN jabatan j ON k.id_jabatan = j.id_jabatan
JOIN gaji g ON k.id_karyawan = g.id_karyawan
GROUP BY d.nama_departemen
HAVING rata_rata_gaji_departemen > 15000000;



-- Studi Kasus: Menampilkan 5 Karyawan dengan Gaji Tertinggi dan Info Masa Kerja

SELECT
    UCASE(k.nama_karyawan) AS NAMA_KARYAWAN,
    j.nama_jabatan,
    -- Sintaks baru untuk menghitung masa kerja
    TIMESTAMPDIFF(YEAR, k.tgl_masuk, CURDATE()) AS masa_kerja_tahun,
    FORMAT((j.gaji_pokok + g.bonus - g.potongan), 0, 'id_ID') AS gaji_bersih_formatted
FROM karyawan k
JOIN jabatan j ON k.id_jabatan = j.id_jabatan
JOIN gaji g ON k.id_karyawan = g.id_karyawan
ORDER BY (j.gaji_pokok + g.bonus - g.potongan) DESC
LIMIT 5;



SELECT
    d.nama_departemen,
    -- Menghitung total karyawan di departemen tersebut (COUNT biasa)
    COUNT(k.id_karyawan) AS total_karyawan,

    -- Implementasi COUNTIF: Menghitung karyawan HANYA JIKA jenis_kelamin = 'L'
    COUNT(CASE WHEN k.jenis_kelamin = 'L' THEN 1 END) AS jumlah_pria,

    -- Implementasi COUNTIF: Menghitung karyawan HANYA JIKA jenis_kelamin = 'P'
    COUNT(CASE WHEN k.jenis_kelamin = 'P' THEN 1 END) AS jumlah_wanita,

    -- Implementasi COUNTIF lainnya: Menghitung karyawan yang masuk setelah tahun 2021
    COUNT(CASE WHEN YEAR(k.tgl_masuk) > 2021 THEN 1 END) AS karyawan_baru_pasca_2021

FROM karyawan k
JOIN departemen d ON k.id_departemen = d.id_departemen
GROUP BY d.nama_departemen;
