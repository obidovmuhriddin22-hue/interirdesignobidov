-- ============================================================
--  CORONA RENDER OPTIMIZER v1.0
--  3ds Max 2024 + Corona Renderer 12
--  Noutbuk uchun: TEZLIK + SIFAT optimizatsiyasi
--  Yorug'likka ziyon yetkazmaydi!
-- ============================================================

macroScript CoronaRenderOptimizer
    category:"Corona Tools"
    tooltip:"Corona Render Optimizer - Tezlik va Sifat"
    buttonText:"Render Optimizer"
    icon:#("Standard",24)
(

global CRO_Dialog = undefined

-- ============================================================
-- YORDAMCHI: Corona render aktivmi?
-- ============================================================
fn CRO_IsCoronaActive = (
    local r = renderers.current
    (matchPattern (classof r as string) pattern:"*Corona*")
)

-- Corona render ob'ektini olish
fn CRO_GetRenderer = renderers.current

-- ============================================================
-- PRESET QO'LLASH FUNKSIYASI
-- Property nomlarini xavfsiz (try/catch) o'rnatadi
-- ============================================================
fn CRO_SetProp r propName val = (
    try ( setProperty r propName val; true ) catch( false )
)

-- ============================================================
-- PRESETLAR
-- Har bir preset yorug'likni saqlaydi, faqat tezlik/shovqin balansini o'zgartiradi
-- ============================================================

-- DRAFT: tezkor ko'rish uchun (eng tez)
fn CRO_ApplyDraft = (
    local r = CRO_GetRenderer()
    CRO_SetProp r "passLimit" 0           -- vaqt bilan cheklash
    CRO_SetProp r "timeLimit" 60          -- 1 daqiqa
    CRO_SetProp r "noiseLimit" 0.05       -- yuqori shovqin (tez)
    CRO_SetProp r "adaptivity" 0.85
    CRO_SetProp r "renderEngineMode" 0    -- High quality (CPU)
    "DRAFT preset qo'llandi: 1 daqiqa, tezkor ko'rish."
)

-- PREVIEW: o'rta sifat (test render)
fn CRO_ApplyPreview = (
    local r = CRO_GetRenderer()
    CRO_SetProp r "passLimit" 0
    CRO_SetProp r "timeLimit" 300         -- 5 daqiqa
    CRO_SetProp r "noiseLimit" 0.03
    CRO_SetProp r "adaptivity" 0.85
    "PREVIEW preset qo'llandi: 5 daqiqa, test sifat."
)

-- FINAL OPTIMIZED: noutbuk uchun yakuniy (sifat + tezlik balansi)
fn CRO_ApplyFinalOptimized = (
    local r = CRO_GetRenderer()
    CRO_SetProp r "passLimit" 0
    CRO_SetProp r "timeLimit" 0           -- vaqt cheklovi yo'q
    CRO_SetProp r "noiseLimit" 0.025      -- toza, lekin oqilona
    CRO_SetProp r "adaptivity" 0.9        -- adaptiv sampling kuchli (tezlik)
    "FINAL OPTIMIZED qo'llandi: shovqin chegarasi 2.5%, adaptiv sampling kuchaytirildi."
)

-- HIGH QUALITY: maksimal sifat (sekin)
fn CRO_ApplyHighQuality = (
    local r = CRO_GetRenderer()
    CRO_SetProp r "passLimit" 0
    CRO_SetProp r "timeLimit" 0
    CRO_SetProp r "noiseLimit" 0.015      -- juda toza
    CRO_SetProp r "adaptivity" 0.9
    "HIGH QUALITY qo'llandi: shovqin 1.5%, maksimal tozalik."
)

-- ============================================================
-- DENOISER (shovqinni tozalovchi) - yorug'likni saqlaydi
-- ============================================================
fn CRO_SetDenoiser mode = (
    local r = CRO_GetRenderer()
    -- mode: 0=None, 1=Corona High Quality, 2=Corona Fast (NVIDIA GPU), 3=Intel
    case mode of (
        0: ( CRO_SetProp r "denoiseAmount" 0.0; "Denoiser OFF" )
        1: ( CRO_SetProp r "denoiseAmount" 1.0; CRO_SetProp r "denoiseType" 1; "Corona High Quality Denoiser yoqildi (eng yaxshi sifat)" )
        2: ( CRO_SetProp r "denoiseAmount" 1.0; CRO_SetProp r "denoiseType" 4; "NVIDIA GPU Denoiser yoqildi (eng tez)" )
        3: ( CRO_SetProp r "denoiseAmount" 0.65; CRO_SetProp r "denoiseType" 1; "Yumshoq Denoiser (0.65) - tabiiy ko'rinish" )
    )
)

-- ============================================================
-- ASOSIY ROLLOUT
-- ============================================================
rollout CRO_Roll "Corona Render Optimizer v1.0" width:430 height:640 (

    label lbl_title "CORONA RENDER OPTIMIZER" align:#center height:18
    label lbl_sub "Noutbuk uchun: Tezlik + Sifat balansi" align:#center
    label lbl_line "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" align:#center

    -- Render holati
    group "Render Holati" (
        label lbl_status "Tekshirilmoqda..." align:#left height:32
        button btn_check "Renderni Tekshirish" width:390 height:26
    )

    -- Asosiy presetlar
    group "Tezkor Presetlar (yorug'likni saqlaydi)" (
        button btn_draft   "1) DRAFT - Tezkor ko'rish (1 daqiqa)"      width:390 height:32
        button btn_preview "2) PREVIEW - Test render (5 daqiqa)"        width:390 height:32
        button btn_final   "3) FINAL - Optimal sifat+tezlik (tavsiya)"  width:390 height:36
        button btn_hq      "4) HIGH QUALITY - Maksimal sifat"           width:390 height:32
    )

    -- Denoiser
    group "Denoiser (shovqin tozalash - yorug'lik saqlanadi)" (
        button btn_dn_hq   "Corona HQ Denoiser (eng toza)"  width:390 height:30
        button btn_dn_gpu  "NVIDIA GPU Denoiser (eng tez)"  width:390 height:30
        button btn_dn_soft "Yumshoq Denoiser (tabiiy)"      width:390 height:30
        button btn_dn_off  "Denoiser O'CHIRISH"             width:390 height:26
    )

    -- Qo'lda sozlash
    group "Qo'lda Aniq Sozlash" (
        spinner spn_noise "Shovqin chegarasi (%):" range:[0.5, 10.0, 2.5] type:#float scale:0.1 width:380
        label lbl_noise_hint "Kichik = tozaroq (sekin) | Katta = tezroq (shovqinli)" align:#left
        spinner spn_time "Vaqt limiti (daqiqa):" range:[0, 120, 0] type:#integer width:380
        label lbl_time_hint "0 = vaqt cheklovsiz (shovqin chegarasigacha)" align:#left
        button btn_apply_manual "Qo'lda Sozlamani Qo'llash" width:390 height:30
    )

    -- Tezlik maslahatlar
    group "Noutbuk uchun Tezlik Maslahatlari" (
        button btn_tips "Maslahatlarni Ko'rsatish" width:390 height:26
    )

    label lbl_msg "Tayyor." align:#center height:30

    -- ============================================================
    -- EVENTLAR
    -- ============================================================

    fn updateStatus = (
        if CRO_IsCoronaActive() then (
            lbl_status.text = ("FAOL: " + (classof renderers.current as string))
            lbl_status.text += "\nCorona render aniqlandi."
        ) else (
            lbl_status.text = "DIQQAT: Corona render faol emas!\nRender Setup > Corona ni tanlang."
        )
    )

    on CRO_Roll open do updateStatus()

    on btn_check pressed do (
        updateStatus()
        lbl_msg.text = "Render holati yangilandi."
    )

    -- Presetlar
    on btn_draft pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_ApplyDraft()
        else lbl_msg.text = "Corona render faol emas!"
    )
    on btn_preview pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_ApplyPreview()
        else lbl_msg.text = "Corona render faol emas!"
    )
    on btn_final pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_ApplyFinalOptimized()
        else lbl_msg.text = "Corona render faol emas!"
    )
    on btn_hq pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_ApplyHighQuality()
        else lbl_msg.text = "Corona render faol emas!"
    )

    -- Denoiser
    on btn_dn_hq pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_SetDenoiser 1
        else lbl_msg.text = "Corona render faol emas!"
    )
    on btn_dn_gpu pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_SetDenoiser 2
        else lbl_msg.text = "Corona render faol emas!"
    )
    on btn_dn_soft pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_SetDenoiser 3
        else lbl_msg.text = "Corona render faol emas!"
    )
    on btn_dn_off pressed do (
        if CRO_IsCoronaActive() then lbl_msg.text = CRO_SetDenoiser 0
        else lbl_msg.text = "Corona render faol emas!"
    )

    -- Qo'lda sozlash
    on btn_apply_manual pressed do (
        if CRO_IsCoronaActive() then (
            local r = CRO_GetRenderer()
            CRO_SetProp r "noiseLimit" (spn_noise.value / 100.0)
            CRO_SetProp r "timeLimit" (spn_time.value * 60)
            CRO_SetProp r "passLimit" 0
            lbl_msg.text = ("Qo'lda sozlandi: shovqin=" + (spn_noise.value as string) + "%, vaqt=" + (spn_time.value as string) + " daqiqa")
        ) else lbl_msg.text = "Corona render faol emas!"
    )

    -- Maslahatlar
    on btn_tips pressed do (
        local tips = "NOUTBUK UCHUN TEZLIK MASLAHATLARI:\n\n"
        tips += "1. FINAL OPTIMIZED preset ishlatib, Denoiser yoqing - eng yaxshi balans.\n\n"
        tips += "2. Shovqin chegarasi 2.5-3% yetarli (ko'z farqlamaydi).\n\n"
        tips += "3. Denoiser SHOVQINNI tozalaydi, yorug'likka tegmaydi - har doim yoqing.\n\n"
        tips += "4. Render paytida boshqa dasturlarni yoping (RAM bo'shating).\n\n"
        tips += "5. Rezolyutsiyani kamaytirib test qiling, faqat finalda oshiring.\n\n"
        tips += "6. Light Mix elementini yoqing - render keyin yorug'likni o'zgartirasiz, qayta render shart emas.\n\n"
        tips += "7. Noutbuk quvvat rejimini 'High Performance' qiling.\n\n"
        tips += "8. Displacement va SSS larni kamroq ishlating - ular sekinlashtiradi."
        messageBox tips title:"Tezlik Maslahatlari"
    )

    on CRO_Roll close do (
        CRO_Dialog = undefined
    )
)

-- ============================================================
-- OYNA OCHISH
-- ============================================================
if CRO_Dialog != undefined do (
    try (destroyDialog CRO_Dialog) catch()
    CRO_Dialog = undefined
)

createDialog CRO_Roll \
    style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing) \
    pos:[120,60]
CRO_Dialog = CRO_Roll

) -- macroScript end
