--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_speakers_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_speakers_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    speakers_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO speakers_count
    FROM event
    WHERE id = NEW.id;

    IF foreign_key_count >= 15 THEN
        RAISE EXCEPTION 'Нельзя добавить более 15 спикеров на одно мероприятие';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_speakers_count() OWNER TO postgres;

--
-- Name: daily_archive_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.daily_archive_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM move_to_archive() FROM calendar WHERE event_date < CURRENT_DATE;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.daily_archive_check() OWNER TO postgres;

--
-- Name: insert_into_archive(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_archive() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Проверка, если дата мероприятия прошла
    IF NEW.event_date < CURRENT_DATE THEN
        -- Вставка записи в таблицу archive
        INSERT INTO archive (event_id, event_headline, event_image_preview, event_type, event_date)
        VALUES (NEW.id, NEW.headline, NEW.preview_image, NEW.type, NEW.event_date);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_into_archive() OWNER TO postgres;

--
-- Name: insert_into_calendar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_calendar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO calendar (event_id, event_headline, event_short_description, event_image_preview, event_type, event_date)
    VALUES (NEW.id, NEW.headline, NEW.short_description, NEW.preview_image, NEW.type, NEW.event_date);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_into_calendar() OWNER TO postgres;

--
-- Name: insert_into_ticket_list(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_ticket_list() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ticket_list (event_id, event_headline, event_image_preview, event_type, event_date)
    VALUES (NEW.id, NEW.headline, NEW.preview_image, NEW.type, NEW.event_date);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_into_ticket_list() OWNER TO postgres;

--
-- Name: move_to_archive(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.move_to_archive() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.event_date < CURRENT_DATE THEN
        INSERT INTO archive (event_id, event_headline, event_image_preview, event_type, event_date)
        VALUES (NEW.event_id, NEW.event_headline, NEW.event_image_preview, NEW.event_type, NEW.event_date);

        DELETE FROM Calendar WHERE event_id = NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.move_to_archive() OWNER TO postgres;

--
-- Name: update_event_details(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_event_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Удаление старых записей
    DELETE FROM event_details WHERE event_id = NEW.id;

    -- Вставка новых записей
   INSERT INTO event_details (event_id, event_headline, event_image, event_type, 
						   event_description, event_short_description,
						   event_format, event_audience, event_date, event_place, 
						   speaker_id, speaker_name, speaker_surname, speaker_role,
						   speaker_image, speaker_description, partner_id, partners_image,
						   partners_name, partners_description)
	SELECT
		e.id AS event_id,
		e.headline AS event_headline,
		e.image AS event_image,
		e.type AS event_type,
		e.description AS event_description,
		e.short_description AS event_short_description,
		e.format AS event_format,
		e.audience AS event_audience,
		e.event_date AS event_date,
		e.place AS event_place,
		s.id AS speaker_id,
		s.name AS speaker_name,
		s.surname AS speaker_surname,
		s.role AS speaker_role,
		s.image AS speaker_image,
		s.description AS speaker_description,
		p.id AS partner_id,
		p.image AS partners_image,
		p.name AS partners_name,
		p.description AS partners_description
	FROM
		event e
	JOIN
		event_speakers es ON e.id = es.event_id
	JOIN
		speakers s ON es.speaker_id = s.id
	JOIN
		event_partners ep ON e.id = ep.event_id
	JOIN
		partners p ON ep.partner_id = p.id
    WHERE e.id = NEW.id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_event_details() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.archive (
    event_id integer NOT NULL,
    event_headline character varying(1000),
    event_image_preview character varying(5000),
    event_type character varying(200),
    event_date date
);


ALTER TABLE public.archive OWNER TO postgres;

--
-- Name: calendar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calendar (
    event_id integer NOT NULL,
    event_headline character varying(1000),
    event_short_description character varying(2500),
    event_image_preview character varying(5000),
    event_type character varying(200),
    event_date date
);


ALTER TABLE public.calendar OWNER TO postgres;

--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    id integer NOT NULL,
    headline character varying(1000),
    description character varying(5000),
    short_description character varying(2500),
    type character varying(200),
    event_date date,
    event_time time without time zone,
    image character varying(5000),
    preview_image character varying(5000),
    place character varying(1000),
    format character varying(200),
    audience character varying(5000)
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: event_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_details (
    event_id integer NOT NULL,
    event_headline character varying(1000),
    event_image character varying(5000),
    event_type character varying(200),
    event_description character varying(5000),
    event_short_description character varying(2500),
    event_format character varying(200),
    event_audience character varying(5000),
    event_date date,
    event_place character varying(1000),
    speaker_id integer NOT NULL,
    speaker_name text,
    speaker_surname text,
    speaker_role text,
    speaker_image character varying(5000),
    speaker_description character varying(5000),
    partner_id integer NOT NULL,
    partners_image character varying(5000),
    partners_name character varying(5000),
    partners_description character varying(5000)
);


ALTER TABLE public.event_details OWNER TO postgres;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.event ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: event_partners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_partners (
    event_id integer NOT NULL,
    partner_id integer NOT NULL
);


ALTER TABLE public.event_partners OWNER TO postgres;

--
-- Name: event_speakers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_speakers (
    event_id integer NOT NULL,
    speaker_id integer NOT NULL
);


ALTER TABLE public.event_speakers OWNER TO postgres;

--
-- Name: partners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.partners (
    id integer NOT NULL,
    image character varying(5000),
    name character varying(5000),
    description character varying(5000)
);


ALTER TABLE public.partners OWNER TO postgres;

--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.partners ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: speakers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.speakers (
    id integer NOT NULL,
    name text,
    surname text,
    role text,
    image character varying(5000),
    description character varying(5000)
);


ALTER TABLE public.speakers OWNER TO postgres;

--
-- Name: speakers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.speakers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.speakers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ticket_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket_list (
    event_id integer NOT NULL,
    event_headline character varying(1000),
    event_image_preview character varying(5000),
    event_type character varying(200),
    event_date date
);


ALTER TABLE public.ticket_list OWNER TO postgres;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    user_id integer NOT NULL,
    event_id integer,
    event_headline character varying(1000),
    event_place character varying(1000),
    event_date date,
    event_time time without time zone,
    ticket_type character varying(200),
    ticket_number integer
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tickets ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_events (
    event_id integer NOT NULL,
    user_id integer NOT NULL,
    event_headline character varying(1000),
    event_type character varying(200),
    event_date date,
    event_image_preview character varying(5000)
);


ALTER TABLE public.user_events OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


ALTER SEQUENCE public.user_id_seq OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    surname text NOT NULL,
    secondname text NOT NULL,
    birth_date date NOT NULL,
    email character varying(100) NOT NULL,
    phone_number character varying(100) NOT NULL,
    password character varying(100) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.users ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: archive; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.archive (event_id, event_headline, event_image_preview, event_type, event_date) FROM stdin;
2	Цифровая медицина 23	preview	II ЕЖЕГОДНАЯ КОНФЕРЕНЦИЯ	2023-03-23
\.


--
-- Data for Name: calendar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calendar (event_id, event_headline, event_short_description, event_image_preview, event_type, event_date) FROM stdin;
3	НАЛОГИ-2024 Налоговый мониторинг и ВЭД	Аудитория: финансовые директора, руководители департаментов налогового планирования и администрирования, руководители по налоговой методологии, налоговые менеджеры, главные бухгалтеры, юристы, руководители налоговой практики аудиторских, юридических и консалтинговых фирм	preview_image	ПРАКТИЧЕСКАЯ КОНФЕРЕНЦИЯ	2024-06-06
6	Субсидиарная ответственность и оспаривание сделок – важные позиции ВС, риски, защита	Цикл конференций «Практика банкротства» СЕГО_ДНЯ – это площадка, на которой каждый может поделиться своим опытом в проведении процедуры банкротства, и каждый может найти ответы на вопросы, о которых не пишут в интернете или открытых источниках.	preview_image	БИЗНЕС-БРАНЧ	2024-06-11
\.


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event (id, headline, description, short_description, type, event_date, event_time, image, preview_image, place, format, audience) FROM stdin;
1	Развитие отрасли\nбеспилотной авиации в России	В течение ближайших шести с половиной лет в России\nдолжна появиться новая отрасль экономики, связанная с\nсозданием и использованием гражданских\nбеспилотников. Такова главная цель Стратегии развития\nбеспилотной авиации до 2030 года и на перспективу до\n2035 года. Распоряжение о её утверждении подписано.\nНаибольший потенциал для применения беспилотников\nимеется в сельском хозяйстве, строительном надзоре,\nсоздании и актуализации геопространственных баз\nданных и доставке грузов в труднодоступные районы.	Ипортозамещение в сфере двигателестроения и микроэлектроники,\nрешение вопроса по сертификации БПЛА и правовому регулированию\nсферы БАС, подготовка и привлечение кадров в беспилотной отрасли.	ФОРСАЙТ-СЕССИЯ	2024-04-22	09:30:00	image	preview	Swissotel Красные Холмы	Кейс-доклады спикеров, вопрос-ответ, public talk	Эксперты рынка, представители топ-менеджмента ведущих транспортных компаний,\nтранспортных операторов и смежных отраслей, компании-производители и эксплуатанты БПЛА,\nинтеграторы цифровых платформ и ИТ-сервисов, поставщики аппаратных и программных\nрешений, а также представители представители профильных ассоциаций, министерств и\nведомств, СМИ
2	Цифровая медицина 23	Цифровое здравоохранение в России является сейчас с одной стороны очень популярной и действительно быстро развивающейся темой, но с другой стороны – очень сложным и рискованным рынком. В нашей стране уже давно и, в целом, сложился его фундамент – сегмент медицинских информационных систем и других программных продуктов для базовой автоматизации. В последнее время активно развиваются такие направления, как телемедицина, мобильные приложения для пациентов и системы искусственного интеллекта. Интернет вещей (IoT), носимые устройства и доступность технологий на базе искусственного интеллекта создают трамплин для развития инноваций в области здравоохранения.	На конференции эксперты в области цифровизации отрасли и представители бизнеса обсудят актуальные вопросы применения цифровых технологий, представят практики использования нововведений и определят точки роста для медицины будущего – эффективной, эргономичной и безбумажной.	II ЕЖЕГОДНАЯ КОНФЕРЕНЦИЯ	2023-03-23	09:30:00	image	preview	Swissotel Красные Холмы	Выступление спикеров с докладами, вопрос-ответ, живая дискуссия	Представители профильных ассоциаций, научных объединений и ИИ; эксперты в области цифровизации отрасли; руководители клиник и главврачи; директора по цифровизации и развитию, финансовые и коммерческие директора, маркетологи и IT-специалисты частных и государственных медицинских учреждений; разработчики и интеграторы решений в сфере цифровизации здравоохранения.
3	НАЛОГИ-2024 Налоговый мониторинг и ВЭД	6 июня 2024 года на площадке центра конференций «Сегодня», в рамках конференции «Налоги-24. Налоговый мониторинг и ВЭД» эксперты-практики поделятся с участниками опытом внедрения системы налогового мониторинга, минимизации налоговых рисков, эффективного взаимодействия с налоговыми органами, а также разберутся в деталях налогового регулирования внешнеэкономической деятельности в России.	Аудитория: финансовые директора, руководители департаментов налогового планирования и администрирования, руководители по налоговой методологии, налоговые менеджеры, главные бухгалтеры, юристы, руководители налоговой практики аудиторских, юридических и консалтинговых фирм	ПРАКТИЧЕСКАЯ КОНФЕРЕНЦИЯ	2024-06-06	09:30:00	image	preview_image	Swissotel Красные Холмы	Кейс-доклады спикеров, вопрос-ответ, public talk	Финансовые директора, руководители департаментов налогового планирования и администрирования, руководители по налоговой методологии, налоговые менеджеры, главные бухгалтеры, юристы, руководители налоговой практики аудиторских, юридических и консалтинговых фирм.
6	Субсидиарная ответственность и оспаривание сделок – важные позиции ВС, риски, защита	Объем ответственности лиц, привлекаемых к субсидиарной ответственности, в России растет с каждым годом и достигает уже десятков миллиардов рублей. Вместе с тем размер предъявленных требований зачастую бывает несоразмерен реальному объему причиненного ответчиком ущерба. По данным Федресурса в 2023 году было подано 3,4 тыс. заявлений о привлечении бизнесменов к субсидиарной ответственности. Из них удовлетворено 1,4 тыс. на общую сумму 303 млрд руб.	Цикл конференций «Практика банкротства» СЕГО_ДНЯ – это площадка, на которой каждый может поделиться своим опытом в проведении процедуры банкротства, и каждый может найти ответы на вопросы, о которых не пишут в интернете или открытых источниках.	БИЗНЕС-БРАНЧ	2024-06-11	09:30:00.313	image	preview_image	Москва | Capo dei Capi	кейс-доклады спикеров, вопрос-ответ, public talk	Программная дирекция центра конференций «Сегодня» благодарит Вас за доверие и ожидание подтверждения всех приглашенных спикеров, мы уже пригласили и ожидаем лучших экспертов!
\.


--
-- Data for Name: event_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_details (event_id, event_headline, event_image, event_type, event_description, event_short_description, event_format, event_audience, event_date, event_place, speaker_id, speaker_name, speaker_surname, speaker_role, speaker_image, speaker_description, partner_id, partners_image, partners_name, partners_description) FROM stdin;
1	Развитие отрасли\nбеспилотной авиации в России	image	ФОРСАЙТ-СЕССИЯ	В течение ближайших шести с половиной лет в России\nдолжна появиться новая отрасль экономики, связанная с\nсозданием и использованием гражданских\nбеспилотников. Такова главная цель Стратегии развития\nбеспилотной авиации до 2030 года и на перспективу до\n2035 года. Распоряжение о её утверждении подписано.\nНаибольший потенциал для применения беспилотников\nимеется в сельском хозяйстве, строительном надзоре,\nсоздании и актуализации геопространственных баз\nданных и доставке грузов в труднодоступные районы.	Ипортозамещение в сфере двигателестроения и микроэлектроники,\nрешение вопроса по сертификации БПЛА и правовому регулированию\nсферы БАС, подготовка и привлечение кадров в беспилотной отрасли.	Кейс-доклады спикеров, вопрос-ответ, public talk	Эксперты рынка, представители топ-менеджмента ведущих транспортных компаний,\nтранспортных операторов и смежных отраслей, компании-производители и эксплуатанты БПЛА,\nинтеграторы цифровых платформ и ИТ-сервисов, поставщики аппаратных и программных\nрешений, а также представители представители профильных ассоциаций, министерств и\nведомств, СМИ	2024-04-22	Swissotel Красные Холмы	1	Людмила	Гонтарь	Эксперт-модератор	image	Руководитель проектного офиса Дирекция «Аэродинамика» (прав.комиссия), руководитель комитета по искусственному интеллекту АНО ГЛОНАС предиктивной аналитики РИЭПП и специальным проектам комиссии ТПП РФ	1	image	СФЕРА ПРАВА	Мы позиционируем себя как стратегический консалтинг, а именно предоставляем правовую поддержку на долгосрочной основе с глубоким погружением в процессы компании и ее сферы деятельности.
1	Развитие отрасли\nбеспилотной авиации в России	image	ФОРСАЙТ-СЕССИЯ	В течение ближайших шести с половиной лет в России\nдолжна появиться новая отрасль экономики, связанная с\nсозданием и использованием гражданских\nбеспилотников. Такова главная цель Стратегии развития\nбеспилотной авиации до 2030 года и на перспективу до\n2035 года. Распоряжение о её утверждении подписано.\nНаибольший потенциал для применения беспилотников\nимеется в сельском хозяйстве, строительном надзоре,\nсоздании и актуализации геопространственных баз\nданных и доставке грузов в труднодоступные районы.	Ипортозамещение в сфере двигателестроения и микроэлектроники,\nрешение вопроса по сертификации БПЛА и правовому регулированию\nсферы БАС, подготовка и привлечение кадров в беспилотной отрасли.	Кейс-доклады спикеров, вопрос-ответ, public talk	Эксперты рынка, представители топ-менеджмента ведущих транспортных компаний,\nтранспортных операторов и смежных отраслей, компании-производители и эксплуатанты БПЛА,\nинтеграторы цифровых платформ и ИТ-сервисов, поставщики аппаратных и программных\nрешений, а также представители представители профильных ассоциаций, министерств и\nведомств, СМИ	2024-04-22	Swissotel Красные Холмы	2	Михаил	Куприянов	Спикер	string	Руководитель перспективных проектов, заведующий кафедрой вычислительной техники Санкт-Петербургского государственного электротехнического университета «ЛЭТИ»	1	image	СФЕРА ПРАВА	Мы позиционируем себя как стратегический консалтинг, а именно предоставляем правовую поддержку на долгосрочной основе с глубоким погружением в процессы компании и ее сферы деятельности.
1	Развитие отрасли\nбеспилотной авиации в России	image	ФОРСАЙТ-СЕССИЯ	В течение ближайших шести с половиной лет в России\nдолжна появиться новая отрасль экономики, связанная с\nсозданием и использованием гражданских\nбеспилотников. Такова главная цель Стратегии развития\nбеспилотной авиации до 2030 года и на перспективу до\n2035 года. Распоряжение о её утверждении подписано.\nНаибольший потенциал для применения беспилотников\nимеется в сельском хозяйстве, строительном надзоре,\nсоздании и актуализации геопространственных баз\nданных и доставке грузов в труднодоступные районы.	Ипортозамещение в сфере двигателестроения и микроэлектроники,\nрешение вопроса по сертификации БПЛА и правовому регулированию\nсферы БАС, подготовка и привлечение кадров в беспилотной отрасли.	Кейс-доклады спикеров, вопрос-ответ, public talk	Эксперты рынка, представители топ-менеджмента ведущих транспортных компаний,\nтранспортных операторов и смежных отраслей, компании-производители и эксплуатанты БПЛА,\nинтеграторы цифровых платформ и ИТ-сервисов, поставщики аппаратных и программных\nрешений, а также представители представители профильных ассоциаций, министерств и\nведомств, СМИ	2024-04-22	Swissotel Красные Холмы	1	Людмила	Гонтарь	Эксперт-модератор	image	Руководитель проектного офиса Дирекция «Аэродинамика» (прав.комиссия), руководитель комитета по искусственному интеллекту АНО ГЛОНАС предиктивной аналитики РИЭПП и специальным проектам комиссии ТПП РФ	2	image	REDFAB	ООО «НПК АНТЕЙ» Мы оказываем услуги контрактного производства полного цикла, начиная от реверс-инжиниринга деталей до оптимизации и постановки изделия в производство на собственных мощностях.
1	Развитие отрасли\nбеспилотной авиации в России	image	ФОРСАЙТ-СЕССИЯ	В течение ближайших шести с половиной лет в России\nдолжна появиться новая отрасль экономики, связанная с\nсозданием и использованием гражданских\nбеспилотников. Такова главная цель Стратегии развития\nбеспилотной авиации до 2030 года и на перспективу до\n2035 года. Распоряжение о её утверждении подписано.\nНаибольший потенциал для применения беспилотников\nимеется в сельском хозяйстве, строительном надзоре,\nсоздании и актуализации геопространственных баз\nданных и доставке грузов в труднодоступные районы.	Ипортозамещение в сфере двигателестроения и микроэлектроники,\nрешение вопроса по сертификации БПЛА и правовому регулированию\nсферы БАС, подготовка и привлечение кадров в беспилотной отрасли.	Кейс-доклады спикеров, вопрос-ответ, public talk	Эксперты рынка, представители топ-менеджмента ведущих транспортных компаний,\nтранспортных операторов и смежных отраслей, компании-производители и эксплуатанты БПЛА,\nинтеграторы цифровых платформ и ИТ-сервисов, поставщики аппаратных и программных\nрешений, а также представители представители профильных ассоциаций, министерств и\nведомств, СМИ	2024-04-22	Swissotel Красные Холмы	2	Михаил	Куприянов	Спикер	string	Руководитель перспективных проектов, заведующий кафедрой вычислительной техники Санкт-Петербургского государственного электротехнического университета «ЛЭТИ»	2	image	REDFAB	ООО «НПК АНТЕЙ» Мы оказываем услуги контрактного производства полного цикла, начиная от реверс-инжиниринга деталей до оптимизации и постановки изделия в производство на собственных мощностях.
\.


--
-- Data for Name: event_partners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_partners (event_id, partner_id) FROM stdin;
1	1
1	2
\.


--
-- Data for Name: event_speakers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_speakers (event_id, speaker_id) FROM stdin;
1	1
1	2
\.


--
-- Data for Name: partners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.partners (id, image, name, description) FROM stdin;
1	image	СФЕРА ПРАВА	Мы позиционируем себя как стратегический консалтинг, а именно предоставляем правовую поддержку на долгосрочной основе с глубоким погружением в процессы компании и ее сферы деятельности.
2	image	REDFAB	ООО «НПК АНТЕЙ» Мы оказываем услуги контрактного производства полного цикла, начиная от реверс-инжиниринга деталей до оптимизации и постановки изделия в производство на собственных мощностях.
\.


--
-- Data for Name: speakers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.speakers (id, name, surname, role, image, description) FROM stdin;
1	Людмила	Гонтарь	Эксперт-модератор	image	Руководитель проектного офиса Дирекция «Аэродинамика» (прав.комиссия), руководитель комитета по искусственному интеллекту АНО ГЛОНАС предиктивной аналитики РИЭПП и специальным проектам комиссии ТПП РФ
2	Михаил	Куприянов	Спикер	string	Руководитель перспективных проектов, заведующий кафедрой вычислительной техники Санкт-Петербургского государственного электротехнического университета «ЛЭТИ»
\.


--
-- Data for Name: ticket_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket_list (event_id, event_headline, event_image_preview, event_type, event_date) FROM stdin;
3	НАЛОГИ-2024 Налоговый мониторинг и ВЭД	preview_image	ПРАКТИЧЕСКАЯ КОНФЕРЕНЦИЯ	2024-06-06
6	Субсидиарная ответственность и оспаривание сделок – важные позиции ВС, риски, защита	preview_image	БИЗНЕС-БРАНЧ	2024-06-11
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (id, user_id, event_id, event_headline, event_place, event_date, event_time, ticket_type, ticket_number) FROM stdin;
\.


--
-- Data for Name: user_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_events (event_id, user_id, event_headline, event_type, event_date, event_image_preview) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, surname, secondname, birth_date, email, phone_number, password) FROM stdin;
1	Иван	Иванов	Иванович	1999-01-21	mail@gmail.com	+71234567890	$2b$12$2T63IO0gaDAI8JacztO9rO38WHiu1IHiXqbt.amlfd7s42YH7pHze
2	Петр	Иванов	Сергеевич	1981-10-11	mail1@gmail.com	+71234567800	$2b$12$qqPDx0rmsnio/tW8fft.mOQzwFJHTcvB3QHVERVC/3q8blFOEDY2u
4	string	string	string	2024-06-07	user@example.com	string	$2b$12$Aofd2IQbYutHrTvHNjWj7OxSv134s2k8lXmdXpK0fjyvgNxgHUuhq
3	admin	admin	admin	2024-05-31	admin@mail.ru	+79773611799	$2b$12$/3w8ENMg9gFik4BKKNVQE.uRyCG7GKtsgVFVs3rpKMRgCVuLzUSxW
\.


--
-- Name: event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_id_seq', 6, true);


--
-- Name: partners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.partners_id_seq', 2, true);


--
-- Name: speakers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.speakers_id_seq', 2, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: users_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq1', 4, true);


--
-- Name: archive archive_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive
    ADD CONSTRAINT archive_pkey PRIMARY KEY (event_id);


--
-- Name: calendar calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (event_id);


--
-- Name: event_details event_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_details
    ADD CONSTRAINT event_details_pkey PRIMARY KEY (event_id, speaker_id, partner_id);


--
-- Name: event_partners event_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_partners
    ADD CONSTRAINT event_partners_pkey PRIMARY KEY (event_id, partner_id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: event_speakers event_speakers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_speakers
    ADD CONSTRAINT event_speakers_pkey PRIMARY KEY (event_id, speaker_id);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: speakers speakers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.speakers
    ADD CONSTRAINT speakers_pkey PRIMARY KEY (id);


--
-- Name: ticket_list ticket_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_list
    ADD CONSTRAINT ticket_list_pkey PRIMARY KEY (event_id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (event_id, user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: event trg_insert_into_archive; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_into_archive AFTER INSERT OR UPDATE ON public.event FOR EACH ROW EXECUTE FUNCTION public.insert_into_archive();


--
-- Name: event trg_insert_into_calendar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_into_calendar AFTER INSERT ON public.event FOR EACH ROW EXECUTE FUNCTION public.insert_into_calendar();


--
-- Name: event trg_insert_into_ticket_list; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_into_ticket_list AFTER INSERT ON public.event FOR EACH ROW EXECUTE FUNCTION public.insert_into_ticket_list();


--
-- Name: event trg_update_event_details_event; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_event_details_event AFTER INSERT OR UPDATE ON public.event FOR EACH ROW EXECUTE FUNCTION public.update_event_details();


--
-- Name: event_partners trg_update_event_details_event_partners; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_event_details_event_partners AFTER INSERT OR UPDATE ON public.event_partners FOR EACH ROW EXECUTE FUNCTION public.update_event_details();


--
-- Name: event_speakers trg_update_event_details_event_speakers; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_event_details_event_speakers AFTER INSERT OR UPDATE ON public.event_speakers FOR EACH ROW EXECUTE FUNCTION public.update_event_details();


--
-- Name: archive archive_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive
    ADD CONSTRAINT archive_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: calendar calendar_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT calendar_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: event_details event_details_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_details
    ADD CONSTRAINT event_details_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: event_details event_details_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_details
    ADD CONSTRAINT event_details_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id);


--
-- Name: event_details event_details_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_details
    ADD CONSTRAINT event_details_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.speakers(id);


--
-- Name: event_partners event_partners_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_partners
    ADD CONSTRAINT event_partners_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: event_partners event_partners_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_partners
    ADD CONSTRAINT event_partners_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id);


--
-- Name: event_speakers event_speakers_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_speakers
    ADD CONSTRAINT event_speakers_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: event_speakers event_speakers_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_speakers
    ADD CONSTRAINT event_speakers_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.speakers(id);


--
-- Name: ticket_list ticket_list_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_list
    ADD CONSTRAINT ticket_list_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: tickets tickets_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: tickets tickets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_events user_events_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: user_events user_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

